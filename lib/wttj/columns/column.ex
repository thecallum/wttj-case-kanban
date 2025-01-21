defmodule Wttj.Columns.Column do
  use Ecto.Schema
  import Ecto.Changeset
  alias Wttj.Candidates.Candidate

  schema "columns" do
    field :label, :string
    field :position, :integer
    field :job_id, :id

    field :lock_version, :integer, default: 1
    has_many :candidates, Candidate

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(column, attrs) do
    column
    |> cast(attrs, [:label, :lock_version, :position, :job_id])
    |> validate_required([:label, :position, :job_id])
  end
end
