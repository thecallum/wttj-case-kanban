defmodule Wttj.Repo.Migrations.AddLockVersionToStatuses do
  use Ecto.Migration

  def change do
    alter table(:statuses) do
      add :lock_version, :integer, default: 1, null: false
    end
  end

  def down do
    alter table(:statuses) do
      remove :lock_version
    end
  end
end
