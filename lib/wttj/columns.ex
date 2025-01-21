defmodule Wttj.Columns do
  @moduledoc """
  The Columns context.
  """

  import Ecto.Query, warn: false
  alias Wttj.Repo
  alias Wttj.Columns.Column

  @doc """
  Returns a list of Columns

  ## Parameters
    * job_id - The id of the job

  ## Returns
    * `[%Column[],]`

  ## Examples
      iex> list_columns(123)
      [%Column[],]
  """
  def list_columns(job_id) do
    Repo.all(from c in Column, where: c.job_id == ^job_id)
  end

  @doc """
  Inserts a column into the database

  ## Parameters
    * attrs - Attributes to add to the new column

  ## Returns
    * `{:error, changeset}` - The insert failed
    * `{:ok, struct}` The column was added to the database
  """
  def create_column(attrs \\ %{}) do
    %Column{}
    |> Column.changeset(attrs)
    |> Repo.insert()
  end
end
