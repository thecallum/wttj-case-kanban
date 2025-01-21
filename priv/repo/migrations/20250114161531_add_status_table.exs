defmodule Wttj.Repo.Migrations.AddStatusTable do
  use Ecto.Migration

  def change do
    create table(:statuses) do
      add :label, :string, null: false
      add :position, :integer, null: false
      add :job_id, references(:jobs, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    alter table(:candidates) do
      remove :status
      add :status_id, references(:statuses, on_delete: :delete_all)
    end
  end

  def down do
    alter table(:candidates) do
      remove :status_id
      add :status, :string
    end

    drop table(:statuses)
  end
end
