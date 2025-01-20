defmodule Wttj.Resolvers.JobTracking do
  alias Wttj.{Jobs, Candidates, Statuses}

  def get_job(_parent, %{job_id: job_id}, _resolution) do
    case Jobs.get_job(job_id) do
      nil -> {:error, "Job not found"}
      job -> {:ok, job}
    end
  end

  def list_jobs(_parent, _args, _resolution) do
    jobs = Jobs.list_jobs()

    {:ok, jobs}
  end

  def list_statuses(_parent, %{job_id: job_id}, _resolution) do
    statuses = Statuses.list_statuses(job_id)

    {:ok, statuses}
  end

  def list_candidates(_parent, %{job_id: job_id}, _resolution) do
    candidates = Candidates.list_candidates(job_id)

    {:ok, candidates}
  end

  def move_candidate(_parent, args, _resolution) do
    subscription_module =
      Application.get_env(:wttj, :subscription_publisher, Absinthe.Subscription)

    with :ok <- validate_status_version(args),
        {:ok, candidate} <-
           Candidates.update_candidate_display_order(
             args[:candidate_id],
             args[:before_index],
             args[:after_index],
             args[:source_status_version],
             args[:destination_status_id],
             args[:destination_status_version]
           ) do
      payload = %{
        candidate: candidate,
        client_id: args.client_id
      }

      subscription_module.publish(
        WttjWeb.Endpoint,
        payload,
        candidate_moved: "candidate_moved:#{candidate.job_id}"
      )

      {:ok, candidate}
    end
  end

  defp validate_status_version(%{destination_status_id: status_id} = args) when not is_nil(status_id) do
    case args do
      %{destination_status_version: version} when not is_nil(version) ->
        :ok
      _ ->
        {:error, "destination_status_version is required when destination_status_id is present"}
    end
  end

  defp validate_status_version(_args), do: :ok
end
