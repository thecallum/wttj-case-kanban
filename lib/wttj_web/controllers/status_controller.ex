defmodule WttjWeb.StatusController do
  use WttjWeb, :controller
  alias Wttj.Statuses

  def index(conn, %{"job_id" => job_id}) do
    statuses = Statuses.list_statuses(job_id)
    render(conn, :index, statuses: statuses)
  end
end
