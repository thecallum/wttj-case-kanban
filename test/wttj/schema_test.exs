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

    test "returns error when job does not exist" do
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
    @move_candidate_mutation """
      mutation MoveCandidate($candidateId: ID!, $beforeIndex: DisplayOrder, $afterIndex: DisplayOrder, $destinationStatusId: ID) {
        moveCandidate(candidateId: $candidateId, beforeIndex: $beforeIndex, afterIndex: $afterIndex, destinationStatusId: $destinationStatusId) {
          email
          id
          jobId
          position
          statusId
          displayOrder
        }
      }
    """

    test "returns ok when moving candidate to empty list" do
      # Arrange
      job1 = job_fixture()
      status1 = status_fixture(%{job_id: job1.id})
      status2 = status_fixture(%{job_id: job1.id})

      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "2"})

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema,
          variables: %{
            "candidateId" => candidate1.id,
            "destinationStatusId" => status2.id
          }
        )

      # Assert
      assert result.data == %{
               "moveCandidate" => %{
                 "email" => candidate1.email,
                 "id" => to_string(candidate1.id),
                 "jobId" => to_string(candidate1.job_id),
                 "position" => candidate1.position,
                 "statusId" => to_string(status2.id),
                 "displayOrder" => "1"
               }
             }
    end

    test "returns ok when moving candidate to top of list" do
      # Arrange
      job1 = job_fixture()
      status1 = status_fixture(%{job_id: job1.id})

      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})
      candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "2"})
      candidate3 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "3"})

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema,
          variables: %{
            "candidateId" => candidate3.id,
            "afterIndex" => candidate1.display_order
            # "destinationStatusId" => status2.id
          }
        )

      # Assert
      assert result.data == %{
               "moveCandidate" => %{
                 "email" => candidate3.email,
                 "id" => to_string(candidate3.id),
                 "jobId" => to_string(candidate3.job_id),
                 "position" => candidate3.position,
                 "statusId" => to_string(status1.id),
                 "displayOrder" => "0.5"
               }
             }
    end

    test "returns ok when moving candidate to bottom of list" do
      # Arrange
      job1 = job_fixture()
      status1 = status_fixture(%{job_id: job1.id})

      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})
      candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "2"})
      candidate3 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "3"})

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema,
          variables: %{
            "candidateId" => candidate1.id,
            "beforeIndex" => candidate3.display_order
          }
        )

      # Assert
      assert result.data == %{
               "moveCandidate" => %{
                 "email" => candidate1.email,
                 "id" => to_string(candidate1.id),
                 "jobId" => to_string(candidate1.job_id),
                 "position" => candidate1.position,
                 "statusId" => to_string(status1.id),
                 "displayOrder" => "4"
               }
             }
    end

    test "returns ok when moving candidate within a list" do
      # Arrange
      job1 = job_fixture()
      status1 = status_fixture(%{job_id: job1.id})

      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "2"})

      candidate3 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "3"})

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema,
          variables: %{
            "candidateId" => candidate1.id,
            "beforeIndex" => candidate2.display_order,
            "afterIndex" => candidate3.display_order
          }
        )

      # Assert
      assert result.data == %{
               "moveCandidate" => %{
                 "email" => candidate1.email,
                 "id" => to_string(candidate1.id),
                 "jobId" => to_string(candidate1.job_id),
                 "position" => candidate1.position,
                 "statusId" => to_string(status1.id),
                 "displayOrder" => "2.5"
               }
             }
    end

    test "returns error when before_index and after_index are invalid format" do
      # Arrange

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema,
          variables: %{
            "candidateId" => 100,
            "beforeIndex" => "1.2s",
            "afterIndex" => "abcd"
          }
        )

      # Assert
      assert Enum.map(result.errors, fn error -> error.message end) == [
               "Argument \"beforeIndex\" has invalid value $beforeIndex.\nInvalid format for type DisplayOrder. Expected a float, but as a string. For example '1', '2.5', '10.99'. The value '0' is not allowed.",
               "Argument \"afterIndex\" has invalid value $afterIndex.\nInvalid format for type DisplayOrder. Expected a float, but as a string. For example '1', '2.5', '10.99'. The value '0' is not allowed."
             ]
    end

    test "returns error when :candidate_id not included" do
      # Arrange
      job1 = job_fixture()
      status1 = status_fixture(%{job_id: job1.id})
      status_fixture(%{job_id: job1.id})
      candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "2"})

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema
        )

      # Assert
      assert Enum.map(result.errors, fn error -> error.message end) == [
               "In argument \"candidateId\": Expected type \"ID!\", found null.",
               "Variable \"candidateId\": Expected non-null, found null."
             ]
    end

    test "returns error when status not owned by job" do
      # Arrange
      job1 = job_fixture()
      job2 = job_fixture()
      status1 = status_fixture(%{job_id: job1.id})
      status2 = status_fixture(%{job_id: job2.id})

      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "2"})

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema,
          variables: %{
            "candidateId" => candidate1.id,
            "destinationStatusId" => status2.id
          }
        )

      # Assert
      assert Enum.map(result.errors, fn error -> error.message end) == [
               "status does not belong to job"
             ]
    end

    test "returns error when candidate not found" do
      # Arrange
      job1 = job_fixture()
      status_fixture(%{job_id: job1.id})

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema,
          variables: %{
            "candidateId" => 100
          }
        )

      # Assert
      assert Enum.map(result.errors, fn error -> error.message end) == [
               "candidate not found"
             ]
    end

    test "returns error when range includes more than 2 candidates" do
      # Arrange
      job1 = job_fixture()
      status1 = status_fixture(%{job_id: job1.id})

      candidate1 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "1"})

      candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "2"})

      candidate3 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "3"})

      candidate4 =
        candidate_fixture(%{job_id: job1.id, status_id: status1.id, display_order: "4"})

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema,
          variables: %{
            "candidateId" => candidate4.id,
            "beforeIndex" => candidate1.display_order,
            "afterIndex" => candidate3.display_order
          }
        )

      # Assert
      assert Enum.map(result.errors, fn error -> error.message end) == [
               "more than two candidates found within range"
             ]
    end
  end
end
