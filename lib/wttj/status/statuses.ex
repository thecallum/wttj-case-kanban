defmodule Wttj.Statuses.Status do
  use Ecto.Schema
  import Ecto.Changeset
  alias Wttj.Candidates.Candidate

  schema "statuses" do
    field :label, :string
    field :position, :integer
    field :job_id, :id

    has_many :candidates, Candidate

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:label, :position, :job_id])
    |> validate_required([:label, :position, :job_id])
  end
end
