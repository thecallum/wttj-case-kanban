defmodule Wttj.StatusesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Wttj.Statuses` context.
  """

  def status_fixture(attrs \\ %{}) do
    {:ok, status} =
      attrs
      |> Enum.into(%{
        label: "some label",
        position: 42
      })
      |> Wttj.Statuses.create_status()

      status
  end

  def create_multiple_statuses(count, attrs \\ %{}) do
    1..count
    |> Enum.map(fn _index -> status_fixture(attrs) end)
  end


end
