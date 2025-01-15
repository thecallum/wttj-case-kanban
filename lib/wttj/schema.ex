defmodule Wttj.Schema do
  use Absinthe.Schema
  import_types Wttj.Types.SchemaTypes

  # def plugins do
    # [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  # end

  alias Wttj.Resolvers

  query do
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
