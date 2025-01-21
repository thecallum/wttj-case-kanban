defmodule Wttj.Resolvers.JobTracking do
  @moduledoc """
  GraphQL resolvers for job tracking functionality.
  """

  alias Wttj.{Jobs, Candidates, Columns}

  @doc """
  Returns a specific job with a matching id.

  ## Parameters
  - args.job_id - The ID of the job

  ## Returns
    * `{:ok, job}` - The job was found
    * `{:error, "Job not found"}` - No job exists with the given ID
  """
  def get_job(_parent, %{job_id: job_id}, _resolution) do
    case Jobs.get_job(job_id) do
      nil -> {:error, "Job not found"}
      job -> {:ok, job}
    end
  end

  @doc """
  Returns a list of jobs

  ## Returns
    * `{:ok, [job]}` - Found a list of jobs
  """
  def list_jobs(_parent, _args, _resolution) do
    jobs = Jobs.list_jobs()

    {:ok, jobs}
  end

  @doc """
  Returns a list of columns for a specific job

  ## Parameters
  - args.job_id - The ID of the job

  ## Returns
    * `{:ok, [job]}` - Found a list of columns
  """
  def list_columns(_parent, %{job_id: job_id}, _resolution) do
    columns = Columns.list_columns(job_id)

    {:ok, columns}
  end

  @doc """
  Returns a list of candidates for a specific job

  ## Parameters
  - args.job_id - The ID of the job

  ## Returns
    * `{:ok, [job]}` - Found a list of candidates
  """
  def list_candidates(_parent, %{job_id: job_id}, _resolution) do
    candidates = Candidates.list_candidates(job_id)

    {:ok, candidates}
  end


  @doc """
  Moves a candidate to a different position within the same or different column.

  This resolver also publishes an event `"candidate_moved:{job_id}"` whenever a candidate is successfully moved.

  ## Parameters
  - args.candidate_id - The ID of the candidate
  - args.previous_candidate_display_order - The displayOrder value of the candidate before the insertion point (or nil)
  - args.next_candidate_display_order - The displayOrder value of the candidate after the insertion point (or nil)
  - args.source_column_version - The lockVersion of the column the candidate started in
  - args.destination_column_id - The id of the column the candidate was moved to
  - args.destination_column_version - The lockVersion of the column the candidate moved to
  - args.client_id - A unique ID of the client (browser) - Is passed into the event so client knows they were the author

  ## Returns
    * `{:ok, %{candidate: candidate, destination_column: column, source_column: column}}` - Successfully moved candidate
    * `{:error, reason}` - Failed to move candidate with given reason

  ## Subscription Event
    Publishes a 'candidate_moved' event with the topic "candidate_moved:{job_id}" containing:
    ```
    %{
      candidate: %Candidate{},
      client_id: String.t(),
      destination_column: %Column{},
      source_column: %Column{},
    }
    ```
  """
  def move_candidate(_parent, args, _resolution) do
    subscription_module =
      Application.get_env(:wttj, :subscription_publisher, Absinthe.Subscription)

    with :ok <- validate_column_version(args),
         {:ok, update} <-
           Candidates.update_candidate_display_order(
             args[:candidate_id],
             args[:previous_candidate_display_order],
             args[:next_candidate_display_order],
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
