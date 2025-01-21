defmodule Wttj.Types.SchemaTypes do
  use Absinthe.Schema.Notation
  alias Wttj.Validation.DisplayOrder

  defp parse_display_order_type(%{value: value}) do
    case DisplayOrder.validate_display_order_type(value) do
      {:ok} -> {:ok, value}
      {:error, message} -> {:error, message}
    end
  end
  defp parse_display_order_type(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  @desc "A string representing a float (e.g. '1', '2.5', '10.99'), cannot be '0'"
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
    field :position, :integer
    field :display_order, :display_order
    field :email, :string
    field :job_id, :id
    field :column_id, :id
  end

  @desc "Return type for candidate_moved subscription"
  object :candidate_moved do
    field :candidate, :candidate
    field :client_id, :string
    field :source_column, :column
    field :destination_column, :column
  end

  object :move_candidate_result do
    field :candidate, :candidate
    field :source_column, :column
    field :destination_column, :column
  end

end
