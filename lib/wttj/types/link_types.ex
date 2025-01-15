defmodule Wttj.Types.LinkTypes do
  use Absinthe.Schema.Notation

  @desc "Contains the details of a specific visit"
  object :visit do
    field :id, :id
    # field :inserted_at, :naive_datetime
    # field :updated_at, :naive_datetime
  end

  object :link do
    field :id, :id
    field :name, :string
    field :description, :string
    field :path, :string
    field :destination, :string

    # field :inserted_at, :naive_datetime
    # field :updated_at, :naive_datetime
  end
end
