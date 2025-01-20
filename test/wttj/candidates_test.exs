defmodule Wttj.CandidatesTest do
  use Wttj.DataCase
  alias Wttj.Repo
  alias Exto.Query, warn: false
  alias Wttj.Candidates
  import Wttj.JobsFixtures
  import Wttj.StatusesFixtures
  import Wttj.CandidatesFixtures
  alias Wttj.Candidates.Candidate
  alias Wttj.Statuses.Status

  setup do
    job1 = job_fixture()
    job2 = job_fixture()
    status1 = status_fixture(%{job_id: job1.id})
    status2 = status_fixture(%{job_id: job1.id})
    status3 = status_fixture(%{job_id: job2.id})

    {:ok, job1: job1, job2: job2, status1: status1, status2: status2, status3: status3}
  end

  @before_status_version 1
  @after_status_version 1

  describe "candidates (existing tests)" do
    alias Wttj.Candidates.Candidate

    import Wttj.CandidatesFixtures

    @invalid_attrs %{position: nil, status: nil, email: nil}

    test "list_candidates/1 returns all candidates for a given job", %{
      job1: job1,
      job2: job2,
      status1: status1,
      status2: status2
    } do
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      _ = candidate_fixture(%{job_id: job2.id, status_id: status2.id, display_order: "1"})
      assert Candidates.list_candidates(job1.id) == [candidate1]
    end

    test "create_candidate/1 with valid data creates a candidate", %{job1: job1, status1: status1} do
      email = unique_user_email()

      valid_attrs = %{
        email: email,
        position: 3,
        job_id: job1.id,
        status_id: status1.id,
        display_order: "1"
      }

      assert {:ok, %Candidate{} = candidate} = Candidates.create_candidate(valid_attrs)
      assert candidate.email == email
      assert {:error, _} = Candidates.create_candidate()
    end

    test "update_candidate/2 with valid data updates the candidate", %{
      job1: job1,
      status1: status1
    } do
      candidate = candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})
      email = unique_user_email()
      update_attrs = %{position: 43, status: :rejected, email: email, status_id: status1.id}

      assert {:ok, %Candidate{} = candidate} =
               Candidates.update_candidate(candidate, update_attrs)

      assert candidate.position == 43
      assert candidate.status_id == status1.id
      assert candidate.email == email
    end

    test "update_candidate/2 with invalid data returns error changeset", %{
      job1: job1,
      status1: status1
    } do
      candidate = candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})
      assert {:error, %Ecto.Changeset{}} = Candidates.update_candidate(candidate, @invalid_attrs)
      assert candidate == Candidates.get_candidate!(job1.id, candidate.id)
    end

    test "change_candidate/1 returns a candidate changeset", %{job1: job1, status1: status1} do
      candidate = candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})
      assert %Ecto.Changeset{} = Candidates.change_candidate(candidate)
    end
  end

  describe "update_candidate_display_order/3 when checking status" do
    test "returns error when status doesnt belong to job",
         %{job1: job1, status1: status1, status3: status3} do
      # Arrange
      candidate =
        candidate_fixture(%{
          job_id: job1.id,
          status_id: status1.id,
          display_order: "1"
        })

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate.id,
          nil,
          nil,
          @before_status_version,
          status3.id,
          @after_status_version
        )

      # Assert
      assert result == {:error, "status does not belong to job"}
    end

    test "returns error when status not found",
         %{job1: job1, status1: status1} do
      # Arrange
      candidate =
        candidate_fixture(%{
          job_id: job1.id,
          status_id: status1.id,
          display_order: "1"
        })

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate.id,
          nil,
          nil,
          @before_status_version,
          100,
          @after_status_version
        )

      # Assert
      assert result == {:error, "status not found"}
    end
  end

  describe "update_candidate_display_order/3 when candidate doesnt exist in the database" do
    test "returns error" do
      # Arrange
      candidate_id = 100

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate_id,
          nil,
          nil,
          @before_status_version
        )

      # Assert
      assert result == {:error, "candidate not found"}
    end
  end

  describe "update_candidate_display_order/3 when moving a candidate with the same empty list" do
    test "returns error when to same list",
         %{job1: job1, status1: status1} do
      # Arrange
      candidate =
        candidate_fixture(%{
          job_id: job1.id,
          status_id: status1.id,
          display_order: "1"
        })

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate.id,
          nil,
          nil,
          @before_status_version,
          status1.id,
          @after_status_version
        )

      # Assert
      assert result == {:error, "candidate already exists in the list youre trying to move it to"}
    end
  end

  describe "update_candidate_display_order/3 returns a version mismatch error" do
    test "when source status version number doesnt match",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange
      candidate =
        candidate_fixture(%{
          job_id: job1.id,
          status_id: status1.id,
          display_order: "1"
        })

      before_status_version = 2

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate.id,
          nil,
          nil,
          before_status_version,
          status2.id,
          @after_status_version
        )

      # Assert
      assert result == {:error, :version_mismatch}
    end

    test "when destination status version number doesnt match",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange
      candidate =
        candidate_fixture(%{
          job_id: job1.id,
          status_id: status1.id,
          display_order: "1"
        })

      after_status_version = 2

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate.id,
          nil,
          nil,
          @before_status_version,
          status2.id,
          after_status_version
        )

      # Assert
      assert result == {:error, :version_mismatch}
    end
  end

  describe "update_candidate_display_order/3 updates status version number" do
    # when source version number doesnt match
    # when destination version number doesnt match

    test "when moving candidate within same column",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{
          job_id: job1.id,
          status_id: status1.id,
          display_order: "1"
        })

      candidate2 =
        candidate_fixture(%{
          job_id: job1.id,
          status_id: status1.id,
          display_order: "2"
        })

      # before_status_version = 2

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate1.id,
          candidate2.display_order,
          nil,
          @before_status_version
          # status2.id,
          # @after_status_version
        )

      # Assert

      assert {:ok, candidate} = result
      assert candidate.display_order == "3"
      assert candidate.status_id == status1.id

      db_response = Repo.get(Status, status1.id)

      assert db_response.lock_version == 2
    end

    test "when moving candidate to a different column",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{
          job_id: job1.id,
          status_id: status1.id,
          display_order: "1"
        })

      # before_status_version = 2

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate1.id,
          nil,
          nil,
          @before_status_version,
          status2.id,
          @after_status_version
        )

      # Assert

      assert {:ok, candidate} = result
      assert candidate.display_order == "1"
      assert candidate.status_id == status2.id

      status1_db_response = Repo.get(Status, status1.id)
      assert status1_db_response.lock_version == 2

      status2_db_response = Repo.get(Status, status2.id)
      assert status2_db_response.lock_version == 2
    end
  end

  describe "update_candidate_display_order/3 when moving a candidate to a different empty list" do
    test "returns error when list isnt empty",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange
      candidate_fixture(%{
        job_id: job1.id,
        status_id: status1.id,
        display_order: "1"
      })

      candiate_in_status_2 =
        candidate_fixture(%{
          job_id: job1.id,
          status_id: status2.id,
          display_order: "1"
        })

      # Act
      result =
        Candidates.update_candidate_display_order(
          candiate_in_status_2.id,
          nil,
          nil,
          @before_status_version,
          status1.id,
          @after_status_version
        )

      # Assert
      assert result == {:error, "cannot insert first candidate in list. others already present"}
    end

    test "returns ok",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange
      candidate =
        candidate_fixture(%{
          job_id: job1.id,
          status_id: status1.id,
          display_order: "1"
        })

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate.id,
          nil,
          nil,
          @before_status_version,
          status2.id,
          @after_status_version
        )

      # Assert
      assert {:ok, candidate} = result
      assert candidate.display_order == "1"
      assert candidate.status_id == status2.id

      db_response = Repo.get(Candidate, candidate.id)
      assert db_response.display_order == "1"
      assert db_response.status_id == status2.id
    end
  end

  describe "update_candidate_display_order/3 when moving a candidate to the beginning of the same list" do
    test "returns ok",
         %{job1: job1, status1: status1} do
      # Arrange
      candidate1 =
        candidate_fixture(%{
          job_id: job1.id,
          status_id: status1.id,
          display_order: "1"
        })

      candidate2 =
        candidate_fixture(%{
          job_id: job1.id,
          status_id: status1.id,
          display_order: "2"
        })

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate2.id,
          nil,
          candidate1.display_order,
          @before_status_version,
          status1.id,
          @after_status_version
        )

      # Assert
      assert {:ok, candidate} = result
      assert candidate.display_order == "0.5"
      assert candidate.status_id == status1.id

      db_response = Repo.get(Candidate, candidate.id)
      assert db_response.display_order == "0.5"
      assert db_response.status_id == status1.id
    end

    test "returns error when more than one display_order found",
         %{job1: job1, status1: status1} do
      # Arrange
      candidate_fixture(%{
        job_id: job1.id,
        status_id: status1.id,
        display_order: "1"
      })

      candidate2 =
        candidate_fixture(%{
          job_id: job1.id,
          status_id: status1.id,
          display_order: "2"
        })

      candidate3 =
        candidate_fixture(%{
          job_id: job1.id,
          status_id: status1.id,
          display_order: "3"
        })

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate3.id,
          nil,
          candidate2.display_order,
          @before_status_version,
          status1.id,
          @after_status_version
        )

      # Assert
      assert {:error, "more than one candidate found within range"} = result
    end

    test "returns error when display_order not found in database",
         %{job1: job1, status2: status2} do
      # Arrange
      candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "2"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate2.id,
          nil,
          "1.5",
          @before_status_version,
          status2.id,
          @after_status_version
        )

      # Assert
      assert {:error, "candidate not found with matching display order"} = result
    end

    test "returns error when display_order",
         %{job1: job1, status1: status1} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate1.id,
          nil,
          "1",
          @before_status_version,
          status1.id,
          @after_status_version
        )

      # Assert
      assert {:error, "no candidates found within range"} = result
    end
  end

  describe "update_candidate_display_order/3 when moving a candidate to the beginning of a different list" do
    test "returns ok",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate2.id,
          nil,
          candidate1.display_order,
          @before_status_version,
          status2.id,
          @after_status_version
        )

      # Assert
      assert {:ok, candidate} = result
      assert candidate.display_order == "0.5"
      assert candidate.status_id == status2.id

      db_response = Repo.get(Candidate, candidate.id)
      assert db_response.display_order == "0.5"
      assert db_response.status_id == status2.id
    end

    test "returns error when more than one display_order found",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange

      candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "2"})

      candidate3 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate3.id,
          nil,
          candidate2.display_order,
          @before_status_version,
          status2.id,
          @after_status_version
        )

      # Assert
      assert {:error, "more than one candidate found within range"} = result
    end

    test "returns error when display_order not found in database",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange

      candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "8"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate2.id,
          nil,
          "1.5",
          @before_status_version,
          status2.id,
          @after_status_version
        )

      # Assert
      assert {:error, "candidate not found with matching display order"} = result
    end

    test "returns error when no candidates found",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate1.id,
          nil,
          "1",
          @before_status_version,
          status2.id,
          @after_status_version
        )

      # Assert
      assert {:error, "no candidates found within range"} == result
    end
  end

  describe "update_candidate_display_order/3 when moving a candidate to the end of the same list" do
    test "returns ok",
         %{job1: job1, status1: status1} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "2"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate1.id,
          candidate2.display_order,
          nil,
          @before_status_version,
          status1.id,
          @after_status_version
        )

      # Assert
      assert {:ok, candidate} = result
      assert candidate.display_order == "3"
      assert candidate.status_id == status1.id

      db_response = Repo.get(Candidate, candidate.id)
      assert db_response.display_order == "3"
      assert db_response.status_id == status1.id
    end

    test "returns error when more than one candidate found",
         %{job1: job1, status1: status1} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "2"})

      candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "3"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate1.id,
          candidate2.display_order,
          nil,
          @before_status_version,
          status1.id,
          @after_status_version
        )

      # Assert
      assert {:error, "more than one candidate found within range"} = result
    end

    test "returns error when display_position not found in database",
         %{job1: job1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "1"})

      candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "2"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate1.id,
          "1.5",
          nil,
          @before_status_version,
          status2.id,
          @after_status_version
        )

      # Assert
      assert {:error, "candidate not found with matching display order"} = result
    end

    test "returns error when no candidates found",
         %{job1: job1, status1: status1} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate1.id,
          "1",
          nil,
          @before_status_version,
          status1.id,
          @after_status_version
        )

      # Assert
      assert {:error, "no candidates found within range"} = result
    end
  end

  describe "update_candidate_display_order/3 when moving a candidate to the end of a different list" do
    test "returns ok",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "2"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "4"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate2.id,
          candidate1.display_order,
          nil,
          @before_status_version,
          status2.id,
          @after_status_version
        )

      # Assert
      assert {:ok, candidate} = result
      assert candidate.display_order == "3"
      assert candidate.status_id == status2.id

      db_response = Repo.get(Candidate, candidate.id)
      assert db_response.display_order == "3"
      assert db_response.status_id == status2.id
    end

    test "returns error when more than one candidate found",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "1"})

      candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "2"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate1.id,
          candidate2.display_order,
          nil,
          @before_status_version,
          status2.id,
          @after_status_version
        )

      # Assert
      assert {:error, "more than one candidate found within range"} = result
    end

    test "returns error when display_position not found in database",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "2"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate1.id,
          "1.5",
          nil,
          @before_status_version,
          status2.id,
          @after_status_version
        )

      # Assert
      assert {:error, "candidate not found with matching display order"} = result
    end

    test "returns error when no candidates found",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate1.id,
          "1",
          nil,
          @before_status_version,
          status2.id,
          @after_status_version
        )

      # Assert
      assert {:error, "no candidates found within range"} = result
    end
  end

  describe "update_candidate_display_order/3 when moving a candidate within the same list" do
    test "returns ok",
         %{job1: job1, status1: status1} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "2"})

      candidate3 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "3"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate3.id,
          candidate1.display_order,
          candidate2.display_order,
          @before_status_version,
          status1.id,
          @after_status_version
        )

      # Assert
      assert {:ok, candidate} = result
      assert candidate.display_order == "1.5"
      assert candidate.status_id == status1.id

      db_response = Repo.get(Candidate, candidate.id)
      assert db_response.display_order == "1.5"
      assert db_response.status_id == status1.id
    end

    test "returns error when more than two candidates returned",
         %{job1: job1, status1: status1} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "2"})

      candidate3 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "3"})

      candidate4 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "4"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate4.id,
          candidate1.display_order,
          candidate3.display_order,
          @before_status_version,
          status1.id,
          @after_status_version
        )

      # Assert
      assert {:error, "more than two candidates found within range"} = result
    end

    test "returns error one of the display positions not found in the database",
         %{job1: job1, status1: status1} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "2"})

      candidate3 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "3"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate3.id,
          candidate1.display_order,
          "1.9",
          @before_status_version,
          status1.id,
          @after_status_version
        )

      # Assert
      assert {:error, "one or more candidate not found"} = result
    end
  end

  describe "update_candidate_display_order/3 when moving a candidate to a different list" do
    test "returns ok",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "2"})

      candidate3 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "3"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate3.id,
          candidate1.display_order,
          candidate2.display_order,
          @before_status_version,
          status1.id,
          @after_status_version
        )

      # Assert
      assert {:ok, candidate} = result
      assert candidate.display_order == "1.5"
      assert candidate.status_id == status1.id

      db_response = Repo.get(Candidate, candidate.id)
      assert db_response.display_order == "1.5"
      assert db_response.status_id == status1.id
    end

    test "returns error when more than two candidates returned",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "2"})

      candidate3 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "3"})

      candidate4 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "4"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate4.id,
          candidate1.display_order,
          candidate3.display_order,
          @before_status_version,
          status1.id,
          @after_status_version
        )

      # Assert
      assert {:error, "more than two candidates found within range"} = result
    end

    test "returns error one of the display positions not found in the database",
         %{job1: job1, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{
          job_id: job1.id,
          status_id: status1.id,
          display_order: "1"
        })

      candidate_fixture(%{
        job_id: job1.id,
        status_id: status1.id,
        display_order: "2"
      })

      candidate3 =
        candidate_fixture(%{
          job_id: job1.id,
          status_id: status2.id,
          display_order: "3"
        })

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate3.id,
          candidate1.display_order,
          "1.9",
          @before_status_version,
          status1.id,
          @after_status_version
        )

      # Assert
      assert {:error, "one or more candidate not found"} = result
    end
  end
end
