defmodule Wttj.Repo.Migrations.RemovePositionFromCandidates do
  use Ecto.Migration

  def up do
    alter table(:candidates) do
      remove :position
    end
  end

  def down do
    alter table(:candidates) do
      add :position, :integer
    end
  end
end
