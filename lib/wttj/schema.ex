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
end
