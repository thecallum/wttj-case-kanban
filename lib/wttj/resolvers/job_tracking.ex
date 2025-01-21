defmodule Wttj.Resolvers.JobTracking do
  alias Wttj.{Jobs, Candidates, Columns}

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

  def list_columns(_parent, %{job_id: job_id}, _resolution) do
    columns = Columns.list_columns(job_id)

    {:ok, columns}
  end

  def list_candidates(_parent, %{job_id: job_id}, _resolution) do
    candidates = Candidates.list_candidates(job_id)

    {:ok, candidates}
  end

  def move_candidate(_parent, args, _resolution) do
    subscription_module =
      Application.get_env(:wttj, :subscription_publisher, Absinthe.Subscription)

    with :ok <- validate_column_version(args),
         {:ok, update} <-
           Candidates.update_candidate_display_order(
             args[:candidate_id],
             args[:before_index],
             args[:after_index],
             args[:source_column_version],
             args[:destination_column_id],
             args[:destination_column_version]
           ) do
      subscription_module.publish(
        WttjWeb.Endpoint,
        %{
          candidate: update.candidate,
          client_id: args.client_id,
          destination_column: update.destination_column,
          source_column: update.source_column,

        },
        candidate_moved: "candidate_moved:#{update.candidate.job_id}"
      )

      {:ok,
       %{
         candidate: update.candidate,
         destination_column: update.destination_column,
         source_column: update.source_column,
       }}
    end
  end

  defp validate_column_version(%{destination_column_id: column_id} = args)
       when not is_nil(column_id) do
    case args do
      %{destination_column_version: version} when not is_nil(version) ->
        :ok

      _ ->
        {:error, "destination_column_version is required when destination_column_id is present"}
    end
  end

  defp validate_column_version(_args), do: :ok
end
