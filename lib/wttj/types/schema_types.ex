defmodule Wttj.Types.SchemaTypes do
  use Absinthe.Schema.Notation

  @desc "Contains the details of a specific job"
  object :job do
    field :id, :id
    field :name, :string
  end

  @desc "Contains the details of a specific status"
  object :status do
    field :id, :id
    field :label, :string
    field :position, :integer
    field :job_id, :id
  end

  @desc "Contains the details of a specific candidate"
  object :candidate do
    field :id, :id
    field :position, :integer
    field :display_order, :string
    field :email, :string
    field :job_id, :id
    field :status_id, :id
  end
end
