defmodule Wttj.Resolvers.JobTrackingTest do
  alias Wttj.Candidates.Candidate
  use Wttj.DataCase
  alias Wttj.Resolvers.JobTracking
  import Wttj.JobsFixtures
  import Wttj.StatusesFixtures
  import Wttj.CandidatesFixtures

  # These tests should probably be mocked, instead of calling the database

  describe "get_job/3" do
    test "returns error when job not found" do
      # Arrange

      # Act
      result = JobTracking.get_job(nil, %{job_id: 100}, nil)

      # Assert
      assert {:error, "Job not found"} = result
    end

    test "returns ok when job found" do
      # Arrange
      job = job_fixture()

      # Act
      result = JobTracking.get_job(nil, %{job_id: job.id}, nil)

      # Assert
      assert {:ok, job} == result
    end
  end

  describe "list_jobs/3" do
    test "returns ok when jobs found" do
      # Arrange
      job1 = job_fixture()
      job2 = job_fixture()
      job3 = job_fixture()

      # Act
      result = JobTracking.list_jobs(nil, nil, nil)

      # Assert
      assert {:ok, [job1, job2, job3]} = result
    end
  end

  describe "list_statuses/3" do
    test "returns ok when statuses found" do
      # Arrange
      job1 = job_fixture()
      job2 = job_fixture()

      status1 = status_fixture(%{job_id: job1.id})
      status2 = status_fixture(%{job_id: job1.id})
      status3 = status_fixture(%{job_id: job2.id})

      # Act
      result = JobTracking.list_statuses(nil, %{job_id: job1.id}, nil)

      # Assert
      assert {:ok, [status1, status2]} = result
    end
  end

  describe "list_candates/3" do
    test "returns ok when candidates found" do
      # Arrange
      job1 = job_fixture()
      status1 = status_fixture(%{job_id: job1.id})

      candidate1 =
        candidate_fixture(%{job_id: job1.id, display_order: "1", status_id: status1.id})

      # Act
      result = JobTracking.list_candidates(nil, %{job_id: job1.id}, nil)

      # Assert
      assert {:ok, [candidate1]} = result
    end
  end

  describe "move_candidate/3" do
    test "returns error when candidate not found" do
      # Arrange
      args = %{
        candidate_id: 100
      }

      # Act
      result = JobTracking.move_candidate(nil, args, nil)

      # Assert
      assert {:error, "candidate not found"} == result
    end

    test "returns ok when transaction is successful" do
      # Arrange
      job = job_fixture()
      status1 = status_fixture(%{job_id: job.id})
      status2 = status_fixture(%{job_id: job.id})
      candidate = candidate_fixture(%{job_id: job.id, status_id: status1.id, display_order: "1"})

      args = %{
        candidate_id: candidate.id,
        before_index: nil,
        after_index: nil,
        destination_status_id: status2.id
      }

      # Act
      result = JobTracking.move_candidate(nil, args, nil)

      # Assert
      assert {:ok, %Candidate{}} = result
    end
  end
end
