defmodule Wttj.Resolvers.JobTracking do
  alias Wttj.Jobs
  alias Wttj.Candidates
  alias Wttj.Statuses

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

end
