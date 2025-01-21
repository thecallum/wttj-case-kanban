defmodule Wttj.Types.SchemaTypes do
  @moduledoc """
  Defines GraphQL types for the job tracking system.
  """

  use Absinthe.Schema.Notation
  alias Wttj.Validation.DisplayOrder

  @doc """
  Parses a display order value from GraphQL input.
  Ensures the value meets the display order requirements.

  ## Examples
      iex> parse_display_order_type(%{value: "1.5"})
      {:ok, "1.5"}

      iex> parse_display_order_type(%{value: "0"})
      {:error, reason}
  """
  defp parse_display_order_type(%{value: value}) do
    case DisplayOrder.validate_display_order_type(value) do
      {:ok} -> {:ok, value}
      {:error, message} -> {:error, message}
    end
  end

  defp parse_display_order_type(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  @desc """
  A string representing a display order value.
  Must be a valid string representation of a float (e.g. '1', '2.5', '10.99').
  Cannot be '0' or negative numbers. Used for ordering candidates within columns.
  """
  scalar :display_order do
    parse(&parse_display_order_type/1)
    serialize(fn value -> value end)
  end

  @desc "Contains the details of a specific job"
  object :job do
    field :id, :id
    field :name, :string
  end

  @desc "Contains the details of a specific column"
  object :column do
    field :id, :id
    field :label, :string
    field :position, :integer
    field :job_id, :id
    field :lock_version, :integer
  end

  @desc "Contains the details of a specific candidate"
  object :candidate do
    field :id, :id
    field :display_order, :display_order
    field :email, :string
    field :job_id, :id
    field :column_id, :id
  end

  @desc "Return type for candidate_moved subscription"
  object :candidate_moved do
    field :candidate, :candidate
    @desc "A unique identifier passed by a client when calling the :candidate_moved subscription, so a client knows it was the origin"
    field :client_id, :string
    @desc "the column the candidate was moved from"
    field :source_column, :column
    @desc "the column the candidate was moved to"
    field :destination_column, :column
  end

  object :move_candidate_result do
    field :candidate, :candidate
    @desc "the column the candidate was moved from"
    field :source_column, :column
    @desc "the column the candidate was moved to"
    field :destination_column, :column
  end

end
