defmodule WttjWeb.StatusJSON do
  alias Wttj.Statuses.Status

  @doc """
  Renders a list of statuses.
  """
  def index(%{statuses: statuses}) do
    %{data: for(status <- statuses, do: data(status))}
  end

  defp data(%Status{} = status) do
    %{
      id: status.id,
      label: status.label,
      position: status.position
    }
  end


end
