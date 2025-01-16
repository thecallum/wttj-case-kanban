defmodule Wttj.Repo.Migrations.AddDisplayOrderFieldToCandidate do
  use Ecto.Migration

  def change do
    alter table(:candidates) do
      add :display_order, :string
    end

    create unique_index(:candidates, [:status_id, :display_order],
      name: :candidates_status_id_display_order_index)
  end

  def down do
    drop index(:candidates, [:status_id, :display_order])

    alter table(:candidates) do
      remove :display_order
    end
  end
end
