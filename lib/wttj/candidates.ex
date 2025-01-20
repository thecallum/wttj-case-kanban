defmodule Wttj.Candidates do
  @moduledoc """
  The Candidates context.
  """

  import Ecto.Query, warn: false
  alias Wttj.Repo
  alias Wttj.Indexing
  alias Wttj.Candidates.Candidate
  alias Wttj.Statuses.Status

  def update_candidate_display_order(
        candidate_id,
        before_index,
        after_index,
        source_status_version,
        destination_status_id \\ nil,
        destination_status_version \\ nil
      ) do
    with {:ok} <-
           validate_destination_status_version(destination_status_id, destination_status_version),
         {:ok, candidate} <- get_candidate_by_id(candidate_id),
         {:ok} <- validate_status_owned_by_board(candidate, destination_status_id),
         {:ok, new_index} <- Indexing.generate_index(before_index, after_index),
         {:ok} <-
           validate_move_candidate(before_index, after_index, candidate, destination_status_id) do
      if !is_nil(destination_status_id) && is_nil(destination_status_version) do
        {:error, "destination_status_version cannot be null"}
      end

      Repo.transaction(fn ->
        # 1. Get both statuses with current versions
        source_status = fetch_and_lock_status(candidate.status_id)
        dest_status = destination_status_id && fetch_and_lock_status(destination_status_id)

        # 2. Version check - fail fast if versions don't match
        if !validate_status_version(source_status, source_status_version) do
          Repo.rollback(:version_mismatch)
        end

        if destination_status_id &&
             !validate_status_version(dest_status, destination_status_version) do
          Repo.rollback(:version_mismatch)
        end

        # 3. If we get here, versions match - do the update
        {:ok, updated_candidate} =
          candidate
          |> Candidate.changeset(%{
            display_order: new_index,
            status_id: destination_status_id || candidate.status_id
          })
          |> Repo.update()

        # 4. Increment both version numbers
        source_status = increment_status_version(source_status)
        dest_status = dest_status && increment_status_version(dest_status)

        # 5. Return the updated candidate
        %{
          candidate: updated_candidate,
          source_status: source_status,
          destination_status: dest_status
        }
      end)
    end
  end

  defp validate_destination_status_version(destination_status_id, destination_status_version) do
    if !is_nil(destination_status_id) && is_nil(destination_status_version) do
      {:error, "destination_status_version cannot be null"}
    else
      {:ok}
    end
  end

  defp fetch_and_lock_status(status_id) do
    from(s in Status,
      where: s.id == ^status_id,
      lock: "FOR UPDATE"
    )
    |> Repo.one!()
  end

  defp validate_status_version(status, provided_version) do
    status.lock_version == provided_version
  end

  defp increment_status_version(status) do
    new_version_number = status.lock_version + 1

    Repo.update!(Status.changeset(status, %{lock_version: new_version_number}))

    # new_version_number
  end

  defp validate_status_owned_by_board(_candidate, nil), do: {:ok}

  defp validate_status_owned_by_board(candidate, destination_status_id) do
    query =
      from s in Status,
        where: s.id == ^destination_status_id

    case Repo.one(query) do
      nil ->
        {:error, "status not found"}

      status ->
        if status.job_id == candidate.job_id do
          {:ok}
        else
          {:error, "status does not belong to job"}
        end
    end
  end

  defp validate_move_candidate(before_index, after_index, candidate, destination_status_id) do
    # board_id = candidate.

    case {before_index, after_index} do
      {nil, nil} ->
        if is_nil(destination_status_id) or candidate.status_id == destination_status_id do
          {:error, "candidate already exists in the list youre trying to move it to"}
        else
          validate_move_candidate_empty_list(
            candidate,
            destination_status_id
          )
        end

      {nil, after_index} ->
        validate_move_candidate_start_of_list(
          candidate.id,
          destination_status_id || candidate.status_id,
          after_index
        )

      {before_index, nil} ->
        validate_move_candidate_end_of_list(
          candidate.id,
          destination_status_id || candidate.status_id,
          before_index
        )

      {before_index, after_index} ->
        validate_move_candidate_middle_of_list(
          candidate.id,
          destination_status_id || candidate.status_id,
          before_index,
          after_index
        )
    end
  end

  defp get_candidate_by_id(candidate_id) do
    case Repo.get(Candidate, candidate_id) do
      nil -> {:error, "candidate not found"}
      candidate -> {:ok, candidate}
    end
  end

  defp validate_move_candidate_empty_list(candidate, status_id) do
    query =
      from c in Candidate,
        where:
          c.status_id == ^status_id and
            not is_nil(c.display_order) and
            c.id != ^candidate.id,
        select: c.display_order

    if Repo.aggregate(query, :count) == 0 do
      {:ok}
    else
      {:error, "cannot insert first candidate in list. others already present"}
    end
  end

  defp validate_move_candidate_start_of_list(candidate_id, status_id, after_index) do
    query =
      from c in Candidate,
        where:
          c.status_id == ^status_id and
            c.display_order <= ^after_index and
            c.id != ^candidate_id,
        order_by: [asc: c.display_order],
        select: c.display_order

    case Repo.all(query) do
      [^after_index] ->
        {:ok}

      result when length(result) > 1 ->
        {:error, "more than one candidate found within range"}

      [_first] ->
        {:error, "candidate not found with matching display order"}

      _ ->
        {:error, "no candidates found within range"}
    end
  end

  defp validate_move_candidate_end_of_list(candidate_id, status_id, before_index) do
    query =
      from c in Candidate,
        where:
          c.status_id == ^status_id and
            c.display_order >= ^before_index and
            c.id != ^candidate_id,
        order_by: [asc: c.display_order],
        select: c.display_order

    case Repo.all(query) do
      [^before_index] ->
        {:ok}

      result when length(result) > 1 ->
        {:error, "more than one candidate found within range"}

      [_first] ->
        {:error, "candidate not found with matching display order"}

      _ ->
        {:error, "no candidates found within range"}
    end
  end

  defp validate_move_candidate_middle_of_list(candidate_id, status_id, before_index, after_index) do
    query =
      from c in Candidate,
        where:
          c.status_id == ^status_id and
            c.display_order >= ^before_index and
            c.display_order <= ^after_index and
            c.id != ^candidate_id,
        order_by: [asc: c.display_order],
        select: c.display_order

    case Repo.all(query) do
      [^before_index, ^after_index] ->
        {:ok}

      result when length(result) > 2 ->
        {:error, "more than two candidates found within range"}

      _ ->
        {:error, "one or more candidate not found"}
    end
  end

  @doc """
  Returns the list of candidates.

  ## Examples

      iex> list_candidates()
      [%Candidate{}, ...]

  """
  def list_candidates(job_id) do
    query = from c in Candidate, where: c.job_id == ^job_id
    Repo.all(query)
  end

  @doc """
  Gets a single candidate.

  Raises `Ecto.NoResultsError` if the Candidate does not exist.

  ## Examples

      iex> get_candidate!(123)
      %Candidate{}

      iex> get_candidate!(456)
      ** (Ecto.NoResultsError)

  """
  def get_candidate!(job_id, id), do: Repo.get_by!(Candidate, id: id, job_id: job_id)

  @doc """
  Creates a candidate.

  ## Examples

      iex> create_candidate(%{field: value})
      {:ok, %Candidate{}}

      iex> create_candidate(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_candidate(attrs \\ %{}) do
    %Candidate{}
    |> Candidate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a candidate.

  ## Examples

      iex> update_candidate(candidate, %{field: new_value})
      {:ok, %Candidate{}}

      iex> update_candidate(candidate, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_candidate(%Candidate{} = candidate, attrs) do
    candidate
    |> Candidate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking candidate changes.

  ## Examples

      iex> change_candidate(candidate)
      %Ecto.Changeset{data: %Candidate{}}

  """
  def change_candidate(%Candidate{} = candidate, attrs \\ %{}) do
    Candidate.changeset(candidate, attrs)
  end
end
