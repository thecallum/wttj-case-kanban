defmodule Wttj.Statuses do
  @moduledoc """
  The Statuses context.
  """

  import Ecto.Query, warn: false
  alias Wttj.Repo
  alias Wttj.Statuses.Status

  @doc """
  Returns a list of statuses
  """
  def list_statuses(job_id) do
    Repo.all(from s in Status, where: s.job_id == ^job_id)
  end

  def create_status(attrs \\ %{}) do
    %Status{}
    |> Status.changeset(attrs)
    |> Repo.insert()
  end
end
