defmodule Wttj.Columns do
  @moduledoc """
  The Columns context.
  """

  import Ecto.Query, warn: false
  alias Wttj.Repo
  alias Wttj.Columns.Column

  @doc """
  Returns a list of Columns
  """
  def list_columns(job_id) do
    Repo.all(from c in Column, where: c.job_id == ^job_id)
  end

  def create_column(attrs \\ %{}) do
    %Column{}
    |> Column.changeset(attrs)
    |> Repo.insert()
  end
end
