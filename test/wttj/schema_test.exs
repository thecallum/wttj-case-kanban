defmodule Wttj.SchemaTest do
  use WttjWeb.ConnCase
  import Wttj.JobsFixtures
  import Wttj.StatusesFixtures
  import Wttj.CandidatesFixtures

  describe "query :job" do
    @get_job_query """
      query GetJob($jobId: ID!) {
        job(jobId: $jobId)  {
          id
          name
        }
      }
    """

    test "returns job when job exists" do
      # Arrange
      job1 = job_fixture()

      # Act
      {:ok, result} =
        Absinthe.run(
          @get_job_query,
          Wttj.Schema,
          variables: %{"jobId" => job1.id}
        )

      # Assert
      assert result.data == %{
               "job" => %{
                 "id" => to_string(job1.id),
                 "name" => job1.name
               }
             }
    end

    test "returns error when job does not exist", %{conn: conn} do
      # Arrange
      {:ok, result} =
        Absinthe.run(
          @get_job_query,
          Wttj.Schema,
          variables: %{"jobId" => "3"}
        )

      # Act
      assert result.data == %{
               "job" => nil
             }

      # Assert
      [%{message: message}] = result.errors
      assert message == "Job not found"
    end
  end

  describe "query :jobs" do
    @list_jobs_query """
      query ListJobs {
        jobs {
          id
          name
        }
      }
    """

    test "returns list of jobs" do
      # Arrange
      job1 = job_fixture()
      job2 = job_fixture()

      # Act
      {:ok, result} =
        Absinthe.run(
          @list_jobs_query,
          Wttj.Schema
        )

      # Assert
      assert result.data == %{
               "jobs" => [
                 %{
                   "id" => to_string(job1.id),
                   "name" => job1.name
                 },
                 %{
                   "id" => to_string(job2.id),
                   "name" => job2.name
                 }
               ]
             }
    end
  end

  describe "query :statuses" do
    @list_statuses_query """
      query ListStatuses($jobId: ID!) {
        statuses(jobId: $jobId)  {
          id
          jobId
          position
          label
        }
      }
    """

    test "returns list of statuses" do
      # Arrange
      job1 = job_fixture()
      status1 = status_fixture(%{job_id: job1.id})
      status2 = status_fixture(%{job_id: job1.id})

      # Act
      {:ok, result} =
        Absinthe.run(
          @list_statuses_query,
          Wttj.Schema,
          variables: %{"jobId" => job1.id}
        )

      # Assert
      assert result.data == %{
               "statuses" => [
                 %{
                   "id" => to_string(status1.id),
                   "jobId" => to_string(status1.job_id),
                   "position" => status1.position,
                   "label" => status1.label
                 },
                 %{
                   "id" => to_string(status2.id),
                   "jobId" => to_string(status2.job_id),
                   "position" => status2.position,
                   "label" => status2.label
                 }
               ]
             }
    end

    test "returns error when :job_id not included" do
      # Arrange

      # Act
      {:ok, result} =
        Absinthe.run(
          @list_statuses_query,
          Wttj.Schema
        )

      # Assert
      assert Enum.map(result.errors, fn error -> error.message end) == [
               "In argument \"jobId\": Expected type \"ID!\", found null.",
               "Variable \"jobId\": Expected non-null, found null."
             ]
    end
  end

  describe "query :candidates" do
    @list_candidates_query """
      query ListCandidates($jobId: ID!) {
        candidates(jobId: $jobId)  {
          email
          id
          jobId
          position
          statusId
          displayOrder
        }
      }
    """

    test "returns list of candidates" do
      # Arrange
      job1 = job_fixture()
      status1 = status_fixture(%{job_id: job1.id})

      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "2"})

      # Act
      {:ok, result} =
        Absinthe.run(
          @list_candidates_query,
          Wttj.Schema,
          variables: %{"jobId" => job1.id}
        )

      # Assert
      assert result.data == %{
               "candidates" => [
                 %{
                   "email" => candidate1.email,
                   "id" => to_string(candidate1.id),
                   "jobId" => to_string(candidate1.job_id),
                   "position" => candidate1.position,
                   "statusId" => to_string(candidate1.status_id),
                   "displayOrder" => candidate1.display_order
                 },
                 %{
                   "email" => candidate2.email,
                   "id" => to_string(candidate2.id),
                   "jobId" => to_string(candidate2.job_id),
                   "position" => candidate2.position,
                   "statusId" => to_string(candidate2.status_id),
                   "displayOrder" => candidate2.display_order
                 }
               ]
             }
    end

    test "returns error when :job_id not included" do
      # Arrange

      # Act
      {:ok, result} =
        Absinthe.run(
          @list_candidates_query,
          Wttj.Schema
        )

      # Assert
      assert Enum.map(result.errors, fn error -> error.message end) == [
               "In argument \"jobId\": Expected type \"ID!\", found null.",
               "Variable \"jobId\": Expected non-null, found null."
             ]
    end
  end

  describe "mutation :move_candidate" do
    test "returns candidate when transaction successful" do
    end

    test "returns error when :candidate_id not included" do
    end

    test "returns error when candidate not found" do
    end
  end
end
