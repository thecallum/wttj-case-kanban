defmodule Wttj.Resolvers.JobTrackingTest do
  use Wttj.DataCase
  alias Wttj.Resolvers.JobTracking
  import Wttj.JobsFixtures
  import Wttj.StatusesFixtures
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

  describe "list_statuses/3" do
    test "returns ok when statuses found" do
      # Arrange
      job1 = job_fixture()
      job2 = job_fixture()

      status1 = status_fixture(%{job_id: job1.id})
      status2 = status_fixture(%{job_id: job1.id})
      status_fixture(%{job_id: job2.id})

      # Act
      result = JobTracking.list_statuses(nil, %{job_id: job1.id}, nil)

      # Assert
      assert {:ok, [status1, status2]} == result
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
      assert {:ok, [candidate1]} == result
    end
  end

  describe "move_candidate/3" do
    @clientId "1234"
    @destination_status_version 1
    @source_status_version 1

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
        destination_status_version: @destination_status_version,
        source_status_version: @source_status_version
      }

      # Act
      result = JobTracking.move_candidate(nil, args, nil)

      # Assert
      assert {:error, "candidate not found"} == result
    end

    test "returns ok and publishes event" do
      # Arrange
      job = job_fixture()
      status1 = status_fixture(%{job_id: job.id})
      status2 = status_fixture(%{job_id: job.id})
      candidate = candidate_fixture(%{job_id: job.id, status_id: status1.id, display_order: "1"})

      args = %{
        candidate_id: candidate.id,
        before_index: nil,
        after_index: nil,
        destination_status_id: status2.id,
        client_id: @clientId,
        destination_status_version: @destination_status_version,
        source_status_version: @source_status_version
      }

      expect(MockSubscription, :publish, fn endpoint, payload, topic ->
        assert endpoint == WttjWeb.Endpoint
        assert payload.candidate.id == candidate.id
        assert payload.client_id == @clientId

        assert payload.source_status.id == status1.id
        assert payload.source_status.lock_version == 2

        assert payload.destination_status.id == status2.id
        assert payload.destination_status.lock_version == 2

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
