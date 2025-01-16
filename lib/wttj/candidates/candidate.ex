defmodule Wttj.Candidates.Candidate do
  use Ecto.Schema
  import Ecto.Changeset
  alias Wttj.Statuses.Status

  schema "candidates" do
    field :position, :integer
    field :display_order, :string
    field :email, :string
    field :job_id, :id

    belongs_to :status, Status

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(candidate, attrs) do
    candidate
    |> cast(attrs, [:email, :status_id, :position, :display_order, :job_id])
    |> validate_required([:email, :status_id, :position, :display_order, :job_id])
    |> unique_constraint([:status_id, :display_order], name: :candidates_status_id_display_order_index)
  end
end
