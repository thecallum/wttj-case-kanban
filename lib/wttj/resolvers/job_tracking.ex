defmodule Wttj.Resolvers.JobTracking do

  def list_jobs(_parent, _args, _resolution) do
    jobs = []

    {:ok, jobs}
  end

  def list_statuses(_parent, _args, _resolution) do
    statuses = []

    {:ok, statuses}
  end

  def list_candidates(_parent, _args, _resolution) do
    candidates = []

    {:ok, candidates}
  end

end
