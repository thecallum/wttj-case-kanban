defmodule Wttj.CandidatesTest do
  use Wttj.DataCase

  alias Wttj.Candidates
  import Wttj.JobsFixtures
  import Wttj.StatusesFixtures

  setup do
    job1 = job_fixture()
    job2 = job_fixture()
    status1 = status_fixture(%{job_id: job1.id})
    status2 = status_fixture(%{job_id: job2.id})
    {:ok, job1: job1, job2: job2, status1: status1, status2: status2}
  end

  describe "candidates" do
    alias Wttj.Candidates.Candidate

    import Wttj.CandidatesFixtures

    @invalid_attrs %{position: nil, status: nil, email: nil}

    test "list_candidates/1 returns all candidates for a given job", %{job1: job1, job2: job2, status1: status1, status2: status2} do
      candidate1 = candidate_fixture(%{job_id: job1.id, status_id: status1.id})
      _ = candidate_fixture(%{job_id: job2.id, status_id: status2.id})
      assert Candidates.list_candidates(job1.id) == [candidate1]
    end

    test "create_candidate/1 with valid data creates a candidate", %{job1: job1, status1: status1} do
      email = unique_user_email()
      valid_attrs = %{email: email, position: 3, job_id: job1.id, status_id: status1.id}
      assert {:ok, %Candidate{} = candidate} = Candidates.create_candidate(valid_attrs)
      assert candidate.email == email
      assert {:error, _} = Candidates.create_candidate()
    end

    test "update_candidate/2 with valid data updates the candidate", %{job1: job1, status1: status1} do
      candidate = candidate_fixture(%{job_id: job1.id, status_id: status1.id})
      email = unique_user_email()
      update_attrs = %{position: 43, status: :rejected, email: email, status_id: status1.id}

      assert {:ok, %Candidate{} = candidate} =
               Candidates.update_candidate(candidate, update_attrs)

      assert candidate.position == 43
      assert candidate.status_id == status1.id
      assert candidate.email == email
    end

    test "update_candidate/2 with invalid data returns error changeset", %{job1: job1, status1: status1} do
      candidate = candidate_fixture(%{job_id: job1.id, status_id: status1.id})
      assert {:error, %Ecto.Changeset{}} = Candidates.update_candidate(candidate, @invalid_attrs)
      assert candidate == Candidates.get_candidate!(job1.id, candidate.id)
    end

    test "change_candidate/1 returns a candidate changeset", %{job1: job1, status1: status1} do
      candidate = candidate_fixture(%{job_id: job1.id, status_id: status1.id})
      assert %Ecto.Changeset{} = Candidates.change_candidate(candidate)
    end
  end
end
