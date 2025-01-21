defmodule Wttj.ColumnsTest do
  use Wttj.DataCase
  alias Wttj.Columns
  import Wttj.ColumnsFixtures
  import Wttj.JobsFixtures

  setup do
    job1 = job_fixture()
    job2 = job_fixture()
    {:ok, job1: job1, job2: job2}
  end

  describe "columns" do
    test "list_columns/1 returns empty list" do
      ## Arrange
      job_id = 100

      ## Act
      response = Columns.list_columns(job_id)

      ## Assert
      assert response == []
    end

    test "list_columns/1 returns relevant columns", %{job1: job1} do
      ## Arrange
      number_of_matching_columns = Enum.random(2..6)
      columns = create_multiple_columns(number_of_matching_columns, %{job_id: job1.id})

      ## Act
      response = Columns.list_columns(job1.id)

      ## Assert
      assert response == columns
    end

    test "list_columns/1 filters out columns for other jobs", %{job1: job1, job2: job2} do
      ## Arrange
      matching_status = column_fixture(%{job_id: job1.id})
      column_fixture(%{job_id: job2.id})

      ## Act
      response = Columns.list_columns(job1.id)

      ## Assert
      assert response == [matching_status]
    end
  end
end
