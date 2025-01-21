defmodule Wttj.StatusesTest do
  use Wttj.DataCase
  alias Wttj.Statuses
  import Wttj.StatusesFixtures
  import Wttj.JobsFixtures

  setup do
    job1 = job_fixture()
    job2 = job_fixture()
    {:ok, job1: job1, job2: job2}
  end

  describe "statuses" do
    test "list_statuses/1 returns empty list" do
      ## Arrange
      job_id = 100

      ## Act
      response = Statuses.list_statuses(job_id)

      ## Assert
      assert response == []
    end

    test "list_statuses/1 returns relevant statuses", %{job1: job1} do
      ## Arrange
      number_of_matching_statuses = Enum.random(2..6)
      statuses = create_multiple_statuses(number_of_matching_statuses, %{job_id: job1.id})

      ## Act
      response = Statuses.list_statuses(job1.id)

      ## Assert
      assert response == statuses
    end

    test "list_statuses/1 filters out statuses for other jobs", %{job1: job1, job2: job2} do
      ## Arrange
      matching_status = status_fixture(%{job_id: job1.id})
      status_fixture(%{job_id: job2.id})

      ## Act
      response = Statuses.list_statuses(job1.id)

      ## Assert
      assert response == [matching_status]
    end
  end
end
