defmodule Wttj.Resolvers.JobTrackingTest do
  alias Wttj.Candidates.Candidate
  use Wttj.DataCase
  alias Wttj.Resolvers.JobTracking
  import Wttj.JobsFixtures
  import Wttj.StatusesFixtures
  import Wttj.CandidatesFixtures

  describe "move_candidate/3" do
    # These tests should probably be mocked, instead of calling the database
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
