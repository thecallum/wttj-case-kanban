defmodule Wttj.Candidates do
  @moduledoc """
  The Candidates context.
  """

  import Ecto.Query, warn: false
  alias Wttj.Repo
  alias Wttj.Indexing
  alias Wttj.Candidates.Candidate
  alias Wttj.Columns.Column

  def update_candidate_display_order(
        candidate_id,
        previous_candidate_display_order,
        next_candidate_display_order,
        source_column_version,
        destination_column_id \\ nil,
        destination_column_version \\ nil
      ) do
    with {:ok} <-
           validate_destination_column_version(destination_column_id, destination_column_version),
         {:ok, candidate} <- get_candidate_by_id(candidate_id),
         {:ok} <- validate_column_owned_by_board(candidate, destination_column_id),
         {:ok, new_display_order} <-
           Indexing.generate_new_display_order(
             previous_candidate_display_order,
             next_candidate_display_order
           ),
         {:ok} <-
           validate_move_candidate(
             previous_candidate_display_order,
             next_candidate_display_order,
             candidate,
             destination_column_id
           ) do
      if !is_nil(destination_column_id) && is_nil(destination_column_version) do
        {:error, "destination_column_version cannot be null"}
      end

      Repo.transaction(fn ->
        # 1. Get both columns with current versions
        source_column = fetch_and_lock_column(candidate.column_id)
        dest_column = destination_column_id && fetch_and_lock_column(destination_column_id)

        # 2. Version check - fail fast if versions don't match
        if !validate_column_version(source_column, source_column_version) do
          Repo.rollback(:version_mismatch)
        end

        if destination_column_id &&
             !validate_column_version(dest_column, destination_column_version) do
          Repo.rollback(:version_mismatch)
        end

        # 3. If we get here, versions match - do the update
        {:ok, updated_candidate} =
          candidate
          |> Candidate.changeset(%{
            display_order: new_display_order,
            column_id: destination_column_id || candidate.column_id
          })
          |> Repo.update()

        # 4. Increment both version numbers
        source_column = increment_column_version(source_column)
        dest_column = dest_column && increment_column_version(dest_column)

        # 5. Return the updated candidate
        %{
          candidate: updated_candidate,
          source_column: source_column,
          destination_column: dest_column
        }
      end)
    end
  end

  defp validate_destination_column_version(destination_column_id, destination_column_version) do
    if !is_nil(destination_column_id) && is_nil(destination_column_version) do
      {:error, "destination_column_version cannot be null"}
    else
      {:ok}
    end
  end

  defp fetch_and_lock_column(column_id) do
    from(s in Column,
      where: s.id == ^column_id,
      lock: "FOR UPDATE"
    )
    |> Repo.one!()
  end

  defp validate_column_version(column, provided_version) do
    column.lock_version == provided_version
  end

  defp increment_column_version(column) do
    new_version_number = column.lock_version + 1

    Repo.update!(Column.changeset(column, %{lock_version: new_version_number}))
  end

  defp validate_column_owned_by_board(_candidate, nil), do: {:ok}

  defp validate_column_owned_by_board(candidate, destination_column_id) do
    query =
      from s in Column,
        where: s.id == ^destination_column_id

    case Repo.one(query) do
      nil ->
        {:error, "column not found"}

      column ->
        if column.job_id == candidate.job_id do
          {:ok}
        else
          {:error, "column does not belong to job"}
        end
    end
  end

  defp validate_move_candidate(
         previous_candidate_display_order,
         next_candidate_display_order,
         candidate,
         destination_column_id
       ) do
    # board_id = candidate.

    case {previous_candidate_display_order, next_candidate_display_order} do
      {nil, nil} ->
        if is_nil(destination_column_id) or candidate.column_id == destination_column_id do
          {:error, "candidate already exists in the list youre trying to move it to"}
        else
          validate_move_candidate_empty_list(
            candidate,
            destination_column_id
          )
        end

      {nil, next_candidate_display_order} ->
        validate_move_candidate_start_of_list(
          candidate.id,
          destination_column_id || candidate.column_id,
          next_candidate_display_order
        )

      {previous_candidate_display_order, nil} ->
        validate_move_candidate_end_of_list(
          candidate.id,
          destination_column_id || candidate.column_id,
          previous_candidate_display_order
        )

      {previous_candidate_display_order, next_candidate_display_order} ->
        validate_move_candidate_middle_of_list(
          candidate.id,
          destination_column_id || candidate.column_id,
          previous_candidate_display_order,
          next_candidate_display_order
        )
    end
  end

  defp get_candidate_by_id(candidate_id) do
    case Repo.get(Candidate, candidate_id) do
      nil -> {:error, "candidate not found"}
      candidate -> {:ok, candidate}
    end
  end

  defp validate_move_candidate_empty_list(candidate, column_id) do
    query =
      from c in Candidate,
        where:
          c.column_id == ^column_id and
            not is_nil(c.display_order) and
            c.id != ^candidate.id,
        select: c.display_order

    if Repo.aggregate(query, :count) == 0 do
      {:ok}
    else
      {:error, "cannot insert first candidate in list. others already present"}
    end
  end

  defp validate_move_candidate_start_of_list(
         candidate_id,
         column_id,
         next_candidate_display_order
       ) do
    query =
      from c in Candidate,
        where:
          c.column_id == ^column_id and
            c.display_order <= ^next_candidate_display_order and
            c.id != ^candidate_id,
        order_by: [asc: c.display_order],
        select: c.display_order

    case Repo.all(query) do
      [^next_candidate_display_order] ->
        {:ok}

      result when length(result) > 1 ->
        {:error, "more than one candidate found within range"}

      [_first] ->
        {:error, "candidate not found with matching display order"}

      _ ->
        {:error, "no candidates found within range"}
    end
  end

  defp validate_move_candidate_end_of_list(
         candidate_id,
         column_id,
         previous_candidate_display_order
       ) do
    query =
      from c in Candidate,
        where:
          c.column_id == ^column_id and
            c.display_order >= ^previous_candidate_display_order and
            c.id != ^candidate_id,
        order_by: [asc: c.display_order],
        select: c.display_order

    case Repo.all(query) do
      [^previous_candidate_display_order] ->
        {:ok}

      result when length(result) > 1 ->
        {:error, "more than one candidate found within range"}

      [_first] ->
        {:error, "candidate not found with matching display order"}

      _ ->
        {:error, "no candidates found within range"}
    end
  end

  defp validate_move_candidate_middle_of_list(
         candidate_id,
         column_id,
         previous_candidate_display_order,
         next_candidate_display_order
       ) do
    query =
      from c in Candidate,
        where:
          c.column_id == ^column_id and
            c.display_order >= ^previous_candidate_display_order and
            c.display_order <= ^next_candidate_display_order and
            c.id != ^candidate_id,
        order_by: [asc: c.display_order],
        select: c.display_order

    case Repo.all(query) do
      [^previous_candidate_display_order, ^next_candidate_display_order] ->
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
