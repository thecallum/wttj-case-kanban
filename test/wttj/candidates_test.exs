defmodule Wttj.CandidatesTest do
  use Wttj.DataCase

  alias Wttj.Candidates
  import Wttj.JobsFixtures
  import Wttj.StatusesFixtures
  import Wttj.CandidatesFixtures

  setup do
    job1 = job_fixture()
    job2 = job_fixture()
    status1 = status_fixture(%{job_id: job1.id})
    status2 = status_fixture(%{job_id: job2.id})

    # candidate1 = candidate_fixture(%{job_id: job2.id, status_id: status1.id, display_order: "1"})
    {:ok, job1: job1, job2: job2, status1: status1, status2: status2}
  end

  describe "candidates (existing tests)" do
    alias Wttj.Candidates.Candidate

    import Wttj.CandidatesFixtures

    @invalid_attrs %{position: nil, status: nil, email: nil}

    # test "list_candidates/1 returns all candidates for a given job", %{job1: job1, job2: job2, status1: status1, status2: status2} do
    #   candidate1 = candidate_fixture(%{job_id: job1.id, status_id: status1.id})
    #   _ = candidate_fixture(%{job_id: job2.id, status_id: status2.id})
    #   assert Candidates.list_candidates(job1.id) == [candidate1]
    # end

    # test "create_candidate/1 with valid data creates a candidate", %{job1: job1, status1: status1} do
    #   email = unique_user_email()
    #   valid_attrs = %{email: email, position: 3, job_id: job1.id, status_id: status1.id}
    #   assert {:ok, %Candidate{} = candidate} = Candidates.create_candidate(valid_attrs)
    #   assert candidate.email == email
    #   assert {:error, _} = Candidates.create_candidate()
    # end

    # test "update_candidate/2 with valid data updates the candidate", %{job1: job1, status1: status1} do
    #   candidate = candidate_fixture(%{job_id: job1.id, status_id: status1.id})
    #   email = unique_user_email()
    #   update_attrs = %{position: 43, status: :rejected, email: email, status_id: status1.id}

    #   assert {:ok, %Candidate{} = candidate} =
    #            Candidates.update_candidate(candidate, update_attrs)

    #   assert candidate.position == 43
    #   assert candidate.status_id == status1.id
    #   assert candidate.email == email
    # end

    # test "update_candidate/2 with invalid data returns error changeset", %{job1: job1, status1: status1} do
    #   candidate = candidate_fixture(%{job_id: job1.id, status_id: status1.id})
    #   assert {:error, %Ecto.Changeset{}} = Candidates.update_candidate(candidate, @invalid_attrs)
    #   assert candidate == Candidates.get_candidate!(job1.id, candidate.id)
    # end

    # test "change_candidate/1 returns a candidate changeset", %{job1: job1, status1: status1} do
    #   candidate = candidate_fixture(%{job_id: job1.id, status_id: status1.id})
    #   assert %Ecto.Changeset{} = Candidates.change_candidate(candidate)
    # end
  end

  describe "update_candidate_display_order/3 when candidate doesnt exist in the database" do
    test "returns error" do
      # Arrange
      candidate_id = 100

      # Act
      result = Candidates.update_candidate_display_order(candidate_id, nil, nil)

      # Assert
      assert result == {:error, "Candidate not found"}
    end
  end

  describe "update_candidate_display_order/3 when moving a candidate with the same, empty list" do
    test "returns error when to same list",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
      # Arrange
      candidate = candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      # Act
      result = Candidates.update_candidate_display_order(candidate.id, nil, nil, status1.id)

      # Assert
      assert result == {:error, "Candidate already exists in list"}
    end
  end

  describe "update_candidate_display_order/3 when moving a candidate to a different, empty list" do
    test "returns error when list isnt empty",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
      # Arrange
      candiate_in_status_1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candiate_in_status_2 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "1"})

      # Act
      result =
        Candidates.update_candidate_display_order(candiate_in_status_2.id, nil, nil, status1.id)

      # Assert
      assert result == {:error, "Cannot insert first indicie. Other indicies found"}
    end

    test "update_candidate_display_order/3 returns ok when moving to empty list",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
      # Arrange
      candidate = candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      # Act
      result = Candidates.update_candidate_display_order(candidate.id, nil, nil, status2.id)

      # Assert
      assert {:ok, candidate} = result
      assert candidate.display_order == "1"
    end
  end

  describe "update_candidate_display_order/3 when moving a candidate to the beginning of the same list" do
    test "returns ok",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "2"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate2.id,
          nil,
          candidate1.display_order,
          status1.id
        )

      # Assert
      assert {:ok, candidate} = result
      assert candidate.display_order == "0.5"
    end

    test "returns error when more than one display_order found",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
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
          nil,
          candidate2.display_order,
          status1.id
        )

      # Assert
      assert {:error, "more than one indicie found"} = result
    end

    test "returns error when display_order not found in database",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "2"})

      # Act
      result = Candidates.update_candidate_display_order(candidate2.id, nil, "1.5", status2.id)

      # Assert
      assert {:error, "Index not found in database: 1, expected 1.5"} = result
    end

    test "returns error when display_order",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      # Act
      result = Candidates.update_candidate_display_order(candidate1.id, nil, "1", status1.id)

      # Assert
      assert {:error, "indicies not found"} = result
    end
  end

  describe "update_candidate_display_order/3 when moving a candidate to the beginning of a different list" do
    test "returns ok",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
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
          status2.id
        )

      # Assert
      assert {:ok, candidate} = result
      assert candidate.display_order == "0.5"
    end

    test "returns error when more than one display_order found",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
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
          status2.id
        )

      # Assert
      assert {:error, "more than one indicie found"} = result
    end

    test "returns error when display_order not found in database",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "8"})

      # Act
      result = Candidates.update_candidate_display_order(candidate2.id, nil, "1.5", status2.id)

      # Assert
      assert {:error, "Index not found in database: 1, expected 1.5"} = result
    end

    test "returns error when no candidates found",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      # Act
      result = Candidates.update_candidate_display_order(candidate1.id, nil, "1", status2.id)

      # Assert
      assert {:error, "indicies not found"} = result
    end
  end

  describe "update_candidate_display_order/3 when moving a candidate to the end of the same list" do
    test "returns ok",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
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
          status1.id
        )

      # Assert
      assert {:ok, candidate} = result
      assert candidate.display_order == "3"
    end

    test "returns error when more than one candidate found",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
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
          candidate1.id,
          candidate2.display_order,
          nil,
          status1.id
        )

      # Assert
      assert {:error, "more than one indicie found"} = result
    end

    test "returns error when display_position not found in database",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "2"})

      # Act
      result = Candidates.update_candidate_display_order(candidate1.id, "1.5", nil, status2.id)

      # Assert
      assert {:error, "Index not found in database: 2, expected 1.5"} = result
    end

    test "returns error when no candidates found",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      # Act
      result = Candidates.update_candidate_display_order(candidate1.id, "1", nil, status1.id)

      # Assert
      assert {:error, "indicies not found"} = result
    end
  end

  describe "update_candidate_display_order/3 when moving a candidate to the end of a different list" do
    test "returns ok",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
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
          status2.id
        )

      # Assert
      assert {:ok, candidate} = result
      assert candidate.display_order == "3"
    end

    test "returns error when more than one candidate found",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "1"})

      candidate3 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "2"})

      # Act
      result =
        Candidates.update_candidate_display_order(
          candidate1.id,
          candidate2.display_order,
          nil,
          status2.id
        )

      # Assert
      assert {:error, "more than one indicie found"} = result
    end

    test "returns error when display_position not found in database",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status2.id, display_order: "2"})

      # Act
      result = Candidates.update_candidate_display_order(candidate1.id, "1.5", nil, status2.id)

      # Assert
      assert {:error, "Index not found in database: 2, expected 1.5"} = result
    end

    test "returns error when no candidates found",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      # Act
      result = Candidates.update_candidate_display_order(candidate1.id, "1", nil, status2.id)

      # Assert
      assert {:error, "indicies not found"} = result
    end
  end

  describe "update_candidate_display_order/3 when moving a candidate within the same list" do
    test "returns ok",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
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
          status1.id
        )

      # Assert
      assert {:ok, candidate} = result
      assert candidate.display_order == "1.5"
    end

    test "returns error when more than two candidates returned",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate2 =
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
          status1.id
        )

      # Assert
      assert {:error, "indicies are not consecutive"} = result
    end

    test "returns error one of the display positions not found in the database",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
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
          "1.9",
          status1.id
        )

      # Assert
      assert {:error, "one or more indicie not found"} = result
    end
  end

  describe "update_candidate_display_order/3 when moving a candidate to a different list" do
    test "returns ok",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
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
          status1.id
        )

      # Assert
      assert {:ok, candidate} = result
      assert candidate.display_order == "1.5"
    end

    test "returns error when more than two candidates returned",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
      # Arrange
      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate2 =
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
          status1.id
        )

      # Assert
      assert {:error, "indicies are not consecutive"} = result
    end

    test "returns error one of the display positions not found in the database",
         %{job1: job1, job2: job2, status1: status1, status2: status2} do
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
          "1.9",
          status1.id
        )

      # Assert
      assert {:error, "one or more indicie not found"} = result
    end
  end
end
