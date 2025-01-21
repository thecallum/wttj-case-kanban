defmodule Wttj.Schema do
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

    @desc "Get all columns"
    field :columns, list_of(:column) do
      arg(:job_id, non_null(:id))
      resolve(&Resolvers.JobTracking.list_columns/3)
    end

    @desc "Get all candidates"
    field :candidates, list_of(:candidate) do
      arg(:job_id, non_null(:id))
      resolve(&Resolvers.JobTracking.list_candidates/3)
    end
  end

  mutation do
    @desc "Move a candidate to a different position"
    field :move_candidate, type: :move_candidate_result do
      arg(:candidate_id, non_null(:id))
      arg(:previous_candidate_display_order, :display_order)
      arg(:next_candidate_display_order, :display_order)
      arg(:client_id, non_null(:string))
      arg(:source_column_version, non_null(:integer))

      arg(:destination_column_id, :id)
      arg(:destination_column_version, :integer)

      resolve(&Resolvers.JobTracking.move_candidate/3)
    end
  end

  subscription do
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
