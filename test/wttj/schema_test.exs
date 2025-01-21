defmodule Wttj.SchemaTest do
  use WttjWeb.ConnCase
  import Wttj.JobsFixtures
  import Wttj.ColumnsFixtures
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
    setup do
      Wttj.Repo.delete_all(Wttj.Jobs.Job)
      :ok
    end

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

  describe "query :columns" do
    @list_columns_query """
      query Listcolumns($jobId: ID!) {
        columns(jobId: $jobId)  {
          id
          jobId
          position
          label
        }
      }
    """

    test "returns list of columns" do
      # Arrange
      job1 = job_fixture()
      column1 = column_fixture(%{job_id: job1.id})
      column2 = column_fixture(%{job_id: job1.id})

      # Act
      {:ok, result} =
        Absinthe.run(
          @list_columns_query,
          Wttj.Schema,
          variables: %{"jobId" => job1.id}
        )

      # Assert
      assert result.data == %{
               "columns" => [
                 %{
                   "id" => to_string(column1.id),
                   "jobId" => to_string(column1.job_id),
                   "position" => column1.position,
                   "label" => column1.label
                 },
                 %{
                   "id" => to_string(column2.id),
                   "jobId" => to_string(column2.job_id),
                   "position" => column2.position,
                   "label" => column2.label
                 }
               ]
             }
    end

    test "returns error when :job_id not included" do
      # Arrange

      # Act
      {:ok, result} =
        Absinthe.run(
          @list_columns_query,
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
          columnId
          displayOrder
        }
      }
    """

    test "returns list of candidates" do
      # Arrange
      job1 = job_fixture()
      column1 = column_fixture(%{job_id: job1.id})

      candidate1 =
        candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "2"})

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
                   "columnId" => to_string(candidate1.column_id),
                   "displayOrder" => candidate1.display_order
                 },
                 %{
                   "email" => candidate2.email,
                   "id" => to_string(candidate2.id),
                   "jobId" => to_string(candidate2.job_id),
                   "columnId" => to_string(candidate2.column_id),
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
      mutation MoveCandidate(
        $candidateId: ID!,
        $beforeIndex: DisplayOrder,
        $afterIndex: DisplayOrder,
        $destinationColumnId: ID,
        $clientId: String!,
        $sourceColumnVersion: Int!,
        $destinationColumnVersion: Int) {
        moveCandidate(
          candidateId: $candidateId,
          beforeIndex: $beforeIndex,
          afterIndex: $afterIndex,
          destinationColumnId: $destinationColumnId,
          clientId: $clientId,
          sourceColumnVersion: $sourceColumnVersion,
          destinationColumnVersion: $destinationColumnVersion) {
          candidate {
            id
            email
            jobId
            displayOrder
            columnId
          }
          sourceColumn {
            id
            lockVersion
          }
          destinationColumn {
            id
            lockVersion
          }
        }
      }
    """
    @client_id "1234abcd"
    @destination_column_version 1
    @source_column_version 1

    test "returns ok when moving candidate to empty list" do
      # Arrange
      job1 = job_fixture()
      column1 = column_fixture(%{job_id: job1.id})
      column2 = column_fixture(%{job_id: job1.id})

      candidate1 =
        candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "2"})

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema,
          variables: %{
            "candidateId" => candidate1.id,
            "destinationColumnId" => column2.id,
            "clientId" => @client_id,
            "sourceColumnVersion" => @source_column_version,
            "destinationColumnVersion" => @destination_column_version
          }
        )

      # Assert
      assert result.data == %{
               "moveCandidate" => %{
                 "candidate" => %{
                   "email" => candidate1.email,
                   "id" => to_string(candidate1.id),
                   "jobId" => to_string(candidate1.job_id),
                   "columnId" => to_string(column2.id),
                   "displayOrder" => "1"
                 },
                 "destinationColumn" => %{
                   "id" => to_string(column2.id),
                   "lockVersion" => 2
                 },
                 "sourceColumn" => %{
                   "id" => to_string(column1.id),
                   "lockVersion" => 2
                 }
               }
             }
    end

    test "returns ok when moving candidate to top of list" do
      # Arrange
      job1 = job_fixture()
      column1 = column_fixture(%{job_id: job1.id})

      candidate1 =
        candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "1"})

      candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "2"})

      candidate3 =
        candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "3"})

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema,
          variables: %{
            "candidateId" => candidate3.id,
            "afterIndex" => candidate1.display_order,
            "clientId" => @client_id,
            "sourceColumnVersion" => @source_column_version
          }
        )

      # Assert
      assert result.data == %{
               "moveCandidate" => %{
                 "candidate" => %{
                   "email" => candidate3.email,
                   "id" => to_string(candidate3.id),
                   "jobId" => to_string(candidate3.job_id),
                   "columnId" => to_string(column1.id),
                   "displayOrder" => "0.5"
                 },
                 "destinationColumn" => nil,
                 "sourceColumn" => %{
                   "id" => to_string(column1.id),
                   "lockVersion" => 2
                 }
               }
             }
    end

    test "returns ok when moving candidate to bottom of list" do
      # Arrange
      job1 = job_fixture()
      column1 = column_fixture(%{job_id: job1.id})

      candidate1 =
        candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "1"})

      candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "2"})

      candidate3 =
        candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "3"})

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema,
          variables: %{
            "candidateId" => candidate1.id,
            "beforeIndex" => candidate3.display_order,
            "clientId" => @client_id,
            "sourceColumnVersion" => @source_column_version
          }
        )

      # Assert
      assert result.data == %{
               "moveCandidate" => %{
                 "candidate" => %{
                   "email" => candidate1.email,
                   "id" => to_string(candidate1.id),
                   "jobId" => to_string(candidate1.job_id),
                   "columnId" => to_string(column1.id),
                   "displayOrder" => "4"
                 },
                 "destinationColumn" => nil,
                 "sourceColumn" => %{
                   "id" => to_string(column1.id),
                   "lockVersion" => 2
                 }
               }
             }
    end

    test "returns ok when moving candidate within a list" do
      # Arrange
      job1 = job_fixture()
      column1 = column_fixture(%{job_id: job1.id})

      candidate1 =
        candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "1"})

      candidate2 =
        candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "2"})

      candidate3 =
        candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "3"})

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema,
          variables: %{
            "candidateId" => candidate1.id,
            "beforeIndex" => candidate2.display_order,
            "afterIndex" => candidate3.display_order,
            "clientId" => @client_id,
            "sourceColumnVersion" => @source_column_version
          }
        )

      # Assert
      assert result.data == %{
               "moveCandidate" => %{
                 "candidate" => %{
                   "email" => candidate1.email,
                   "id" => to_string(candidate1.id),
                   "jobId" => to_string(candidate1.job_id),
                   "columnId" => to_string(column1.id),
                   "displayOrder" => "2.5"
                 },
                 "destinationColumn" => nil,
                 "sourceColumn" => %{
                   "id" => to_string(column1.id),
                   "lockVersion" => 2
                 }
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
            "afterIndex" => "abcd",
            "clientId" => @client_id,
            "sourceColumnVersion" => @source_column_version
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
      column1 = column_fixture(%{job_id: job1.id})
      column_fixture(%{job_id: job1.id})
      candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "2"})

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema,
          variables: %{
            "clientId" => @client_id,
            "sourceColumnVersion" => @source_column_version
          }
        )

      # Assert
      assert Enum.map(result.errors, fn error -> error.message end) == [
               "In argument \"candidateId\": Expected type \"ID!\", found null.",
               "Variable \"candidateId\": Expected non-null, found null."
             ]
    end

    test "returns error when column not owned by job" do
      # Arrange
      job1 = job_fixture()
      job2 = job_fixture()
      column1 = column_fixture(%{job_id: job1.id})
      column2 = column_fixture(%{job_id: job2.id})

      candidate1 =
        candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "2"})

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema,
          variables: %{
            "candidateId" => candidate1.id,
            "destinationColumnId" => column2.id,
            "clientId" => @client_id,
            "sourceColumnVersion" => @source_column_version,
            "destinationColumnVersion" => @destination_column_version
          }
        )

      # Assert
      assert Enum.map(result.errors, fn error -> error.message end) == [
               "column does not belong to job"
             ]
    end

    test "returns error when candidate not found" do
      # Arrange
      job1 = job_fixture()
      column_fixture(%{job_id: job1.id})

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema,
          variables: %{
            "candidateId" => 100,
            "clientId" => @client_id,
            "sourceColumnVersion" => @source_column_version
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
      column1 = column_fixture(%{job_id: job1.id})

      candidate1 =
        candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "1"})

      candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "2"})

      candidate3 =
        candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "3"})

      candidate4 =
        candidate_fixture(%{job_id: job1.id, column_id: column1.id, display_order: "4"})

      # Act
      {:ok, result} =
        Absinthe.run(
          @move_candidate_mutation,
          Wttj.Schema,
          variables: %{
            "candidateId" => candidate4.id,
            "beforeIndex" => candidate1.display_order,
            "afterIndex" => candidate3.display_order,
            "clientId" => @client_id,
            "sourceColumnVersion" => @source_column_version
          }
        )

      # Assert
      assert Enum.map(result.errors, fn error -> error.message end) == [
               "more than two candidates found within range"
             ]
    end
  end
end
