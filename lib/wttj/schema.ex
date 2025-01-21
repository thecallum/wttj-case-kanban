defmodule Wttj.Schema do
  @moduledoc """
  GraphQL schema for the job tracking system.
  """

  use Absinthe.Schema
  import_types(Wttj.Types.SchemaTypes)
  alias Wttj.Resolvers

  query do
    @desc "Get job by id"
    field :job, type: :job do
      arg(:job_id, non_null(:id))
      resolve(&Resolvers.JobTracking.get_job/3)
    end

    @desc "Get all jobs"
    field :jobs, list_of(:job) do
      resolve(&Resolvers.JobTracking.list_jobs/3)
    end

    @desc "Get all columns for a specific job"
    field :columns, list_of(:column) do
      arg(:job_id, non_null(:id))
      resolve(&Resolvers.JobTracking.list_columns/3)
    end

    @desc "Get all candidates for a specific job"
    field :candidates, list_of(:candidate) do
      arg(:job_id, non_null(:id))
      resolve(&Resolvers.JobTracking.list_candidates/3)
    end
  end

  mutation do
    @desc "Move a candidate to a different position within the same or a different column"
    field :move_candidate, type: :move_candidate_result do
      arg(:candidate_id, non_null(:id))
      @desc "The display order of the candidate before the insertion point"
      arg(:previous_candidate_display_order, :display_order)
      @desc "The display order of the candidate before the insertion point"
      arg(:next_candidate_display_order, :display_order)
      @desc "A unique identifier passed by a client when calling the :candidate_moved subscription, so a client knows it was the origin"
      arg(:client_id, non_null(:string))
      @desc "The lock_version of the column the candidate started in"
      arg(:source_column_version, non_null(:integer))
      @desc "The id of the column the candidate is moving to"
      arg(:destination_column_id, :id)
      @desc "The lock_version of the column the candidate is moving to"
      arg(:destination_column_version, :integer)

      resolve(&Resolvers.JobTracking.move_candidate/3)
    end
  end

  subscription do
    @desc """
    Subscribe to candidate movement events within a specific job.
    Notifies when candidates are moved within or between columns.
    """
    field :candidate_moved, :candidate_moved do
      arg(:job_id, non_null(:id))

      config(fn args, context ->
        {:ok,
         %{
           topic: "candidate_moved:#{args.job_id}",
           context: context
         }}
      end)
    end
  end
end
