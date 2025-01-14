defmodule Wttj.Candidates.Candidate do
  use Ecto.Schema
  import Ecto.Changeset
  alias Wttj.Status.Status

  schema "candidates" do
    field :position, :integer
    field :email, :string
    field :job_id, :id

    belongs_to :status, Status

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(candidate, attrs) do
    candidate
    |> cast(attrs, [:email, :status, :position, :job_id])
    |> validate_required([:email, :status, :position, :job_id])
  end
end
