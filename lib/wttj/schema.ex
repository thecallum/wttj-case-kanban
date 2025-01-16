defmodule Wttj.Schema do
  use Absinthe.Schema
  import_types Wttj.Types.SchemaTypes

  alias Wttj.Resolvers

  query do
    @desc "Get job by id"
    field :job, type: :job do
      arg :job_id, non_null(:id)
      resolve &Resolvers.JobTracking.get_job/3
    end

    @desc "Get all jobs"
    field :jobs, list_of(:job) do
      resolve &Resolvers.JobTracking.list_jobs/3
    end

    @desc "Get all statuses"
    field :statuses, list_of(:status) do
      arg :job_id, non_null(:id)
      resolve &Resolvers.JobTracking.list_statuses/3
    end

    @desc "Get all candidates"
    field :candidates, list_of(:candidate) do
      arg :job_id, non_null(:id)
      resolve &Resolvers.JobTracking.list_candidates/3
    end
  end

  mutation do
    @desc "Move a candidate to a different position"
    field :move_candidate, type: :candidate do
      arg :candidate_id, non_null(:id)
      arg :before_index, :string
      arg :after_index, :string
      arg :destination_status_id, :id
      resolve &Resolvers.JobTracking.move_candidate/3
    end
  end
end
