defmodule Wttj.Candidates do
  @moduledoc """
  The Candidates context.
  """

  import Ecto.Query, warn: false
  alias Wttj.Repo
  alias Wttj.Indexing
  alias Wttj.Candidates.Candidate

  defp get_candidate_by_id(candidate_id) do
    case Repo.get(Candidate, candidate_id) do
      nil -> {:error, "Candidate not found"}
      candidate -> {:ok, candidate}
    end
  end

  defp get_num_candidates_in_column(candidate_id, status_id) do
    query =
      from c in Candidate,
        where:
          c.status_id == ^status_id and
            not is_nil(c.display_order) and
            c.id != ^candidate_id,
        select: c.display_order

    Repo.aggregate(query, :count)
  end

  defp get_index_candidate_display_order_empty_column(candidate, status_id) do
    case get_num_candidates_in_column(candidate.id, status_id) do
      0 ->
        # valid, column is empty
        {:ok, Indexing.generate_index(nil, nil)}

      _ ->
        {:error, "Cannot insert first indicie. Other indicies found"}
    end
  end

  @spec update_candidate_display_order(any(), any(), any(), any()) :: any()
  def update_candidate_display_order(
        candidate_id,
        before_index,
        after_index,
        destination_status_id \\ nil
      ) do
    case get_candidate_by_id(candidate_id) do
      {:error, message} ->
        {:error, message}

      {:ok, candidate} ->
        case {before_index, after_index} do
          {nil, nil} ->
            if is_nil(destination_status_id) or candidate.status_id == destination_status_id do
              {:error, "Candidate already exists in list"}
            else
              case get_index_candidate_display_order_empty_column(
                     candidate,
                     destination_status_id
                   ) do
                {:ok, new_index} ->
                  Repo.update(Candidate.changeset(candidate, %{display_order: new_index}))

                {:error, message} ->
                  {:error, message}
              end
            end

          {nil, after_index} ->
            # insert at beginning of list

            status_id = destination_status_id || candidate.status_id

            case get_index_start_of_column(candidate_id, status_id, after_index) do
              {:ok, new_index} ->
                Repo.update(Candidate.changeset(candidate, %{display_order: new_index}))

              {:error, message} ->
                {:error, message}
            end

          {before_index, nil} ->
            # insert at end of list
            status_id = destination_status_id || candidate.status_id

            case get_index_end_of_column(candidate_id, status_id, before_index) do
              {:ok, new_index} ->
                Repo.update(Candidate.changeset(candidate, %{display_order: new_index}))

              {:error, message} ->
                {:error, message}
            end

          {before_index, after_index} ->
            # insert into middle
            status_id = destination_status_id || candidate.status_id
            case verify_consecutive_indicies(
                   candidate_id,
                   status_id,
                   before_index,
                   after_index
                 ) do
              {:ok, new_index} ->
                Repo.update(Candidate.changeset(candidate, %{display_order: new_index}))

              {:error, message} ->
                {:error, message}
            end
        end
    end
  end

  defp get_index_start_of_column(candidate_id, status_id, after_index) do
    query =
      from c in Candidate,
        where:
          c.status_id == ^status_id and
            c.display_order <= ^after_index and
            c.id != ^candidate_id,
        order_by: [asc: c.display_order],
        # filter out the existing index
        select: c.display_order

    result = Repo.all(query)

    case result do
      [^after_index] ->
        # {:ok, "after index is first"}
        {:ok, Indexing.generate_index(nil, after_index)}

      result when length(result) > 1 ->
        {:error, "more than one indicie found"}

      [first] ->
        {:error, "Index not found in database: #{first}, expected #{after_index}"}

      _ ->
        {:error, "indicies not found"}
    end
  end

  defp get_index_end_of_column(candidate_id, status_id, before_index) do
    query =
      from c in Candidate,
        where:
          c.status_id == ^status_id and
            c.display_order >= ^before_index and
            c.id != ^candidate_id,
        order_by: [asc: c.display_order],
        # filter out the existing index
        select: c.display_order

    result = Repo.all(query)

    case result do
      [^before_index] ->
        # {:ok, "after index is first"}
        {:ok, Indexing.generate_index(before_index, nil)}

      result when length(result) > 1 ->
        {:error, "more than one indicie found"}

      [first] ->
        {:error, "Index not found in database: #{first}, expected #{before_index}"}

      _ ->
        {:error, "indicies not found"}
    end
  end

  def verify_consecutive_indicies(candidate_id, status_id, before_index, after_index) do
    # Candidates.update_candidate_display_order(4, "2", "2.4")

    # "display_order"
    # "2"
    # "2.25"
    # "2.4375"

    # This would return a count of 2, resulting in an index of 2.2.
    # This might not be the correct positioning

    query =
      from c in Candidate,
        where:
          c.status_id == ^status_id and
            c.display_order >= ^before_index and
            c.display_order <= ^after_index and
            c.id != ^candidate_id,
        order_by: [asc: c.display_order],
        # filter out the existing index
        select: c.display_order

    result = Repo.all(query)

    IO.puts("result")
    IO.puts(result)
    IO.puts(length(result))

    case result do
      [^before_index, ^after_index] ->
        {:ok, Indexing.generate_index(before_index, after_index)}

      result when length(result) > 2 ->
        {:error, "indicies are not consecutive"}

      _ ->
        {:error, "one or more indicie not found"}
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
