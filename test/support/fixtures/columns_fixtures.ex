defmodule Wttj.ColumnsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Wttj.Columns` context.
  """

  def column_fixture(attrs \\ %{}) do
    {:ok, column} =
      attrs
      |> Enum.into(%{
        label: "some label",
        position: 42
      })
      |> Wttj.Columns.create_column()

      column
  end

  def create_multiple_columns(count, attrs \\ %{}) do
    1..count
    |> Enum.map(fn _index -> column_fixture(attrs) end)
  end


end
