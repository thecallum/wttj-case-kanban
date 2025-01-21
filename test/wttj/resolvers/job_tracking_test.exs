defmodule Wttj.Resolvers.JobTrackingTest do
  use Wttj.DataCase
  alias Wttj.Resolvers.JobTracking
  import Wttj.JobsFixtures
  import Wttj.ColumnsFixtures
  import Wttj.CandidatesFixtures
  import Mox

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
    setup do
      Wttj.Repo.delete_all(Wttj.Jobs.Job)
      :ok
    end

    test "returns ok when jobs found" do
      # Arrange
      job1 = job_fixture()
      job2 = job_fixture()
      job3 = job_fixture()

      # Act
      result = JobTracking.list_jobs(nil, nil, nil)

      # Assert
      assert {:ok, [job1, job2, job3]} == result
    end
  end

  describe "list_columns/3" do
    test "returns ok when columns found" do
      # Arrange
      job1 = job_fixture()
      job2 = job_fixture()

      column1 = column_fixture(%{job_id: job1.id})
      column2 = column_fixture(%{job_id: job1.id})
      column_fixture(%{job_id: job2.id})

      # Act
      result = JobTracking.list_columns(nil, %{job_id: job1.id}, nil)

      # Assert
      assert {:ok, [column1, column2]} == result
    end
  end

  describe "list_candates/3" do
    test "returns ok when candidates found" do
      # Arrange
      job1 = job_fixture()
      column1 = column_fixture(%{job_id: job1.id})

      candidate1 =
        candidate_fixture(%{job_id: job1.id, display_order: "1", column_id: column1.id})

      # Act
      result = JobTracking.list_candidates(nil, %{job_id: job1.id}, nil)

      # Assert
      assert {:ok, [candidate1]} == result
    end
  end

  describe "move_candidate/3" do
    @clientId "1234"
    @destination_column_version 1
    @source_column_version 1

    defmodule WTTJ.Subscription do
      @callback publish(Plug.Conn.t() | atom(), map(), keyword()) :: :ok | {:error, term()}
    end

    # Define the mock using the behaviour we just defined
    Mox.defmock(MockSubscription, for: WTTJ.Subscription)

    setup do
      Application.put_env(:wttj, :subscription_publisher, MockSubscription)

      on_exit(fn ->
        Application.put_env(:wttj, :subscription_publisher, MockSubscription)
      end)

      :ok
    end

    test "returns error when candidate not found" do
      # Arrange
      args = %{
        candidate_id: 100,
        client_id: @clientId,
        destination_column_version: @destination_column_version,
        source_column_version: @source_column_version
      }

      # Act
      result = JobTracking.move_candidate(nil, args, nil)

      # Assert
      assert {:error, "candidate not found"} == result
    end

    test "returns ok and publishes event" do
      # Arrange
      job = job_fixture()
      column1 = column_fixture(%{job_id: job.id})
      column2 = column_fixture(%{job_id: job.id})
      candidate = candidate_fixture(%{job_id: job.id, column_id: column1.id, display_order: "1"})

      args = %{
        candidate_id: candidate.id,
        before_index: nil,
        after_index: nil,
        destination_column_id: column2.id,
        client_id: @clientId,
        destination_column_version: @destination_column_version,
        source_column_version: @source_column_version
      }

      expect(MockSubscription, :publish, fn endpoint, payload, topic ->
        assert endpoint == WttjWeb.Endpoint
        assert payload.candidate.id == candidate.id
        assert payload.client_id == @clientId

        assert payload.source_column.id == column1.id
        assert payload.source_column.lock_version == 2

        assert payload.destination_column.id == column2.id
        assert payload.destination_column.lock_version == 2

        assert topic == [candidate_moved: "candidate_moved:#{job.id}"]
        :ok
      end)
      # Act
      result = JobTracking.move_candidate(nil, args, nil)

      # Assert
      assert {:ok, %{candidate: _candidate}} = result

    end
  end
end
