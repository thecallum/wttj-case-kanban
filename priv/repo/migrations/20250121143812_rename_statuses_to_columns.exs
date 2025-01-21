defmodule Wttj.Repo.Migrations.RenameStatusesToColumns do
  use Ecto.Migration

  def up do
    # First drop the existing index
    drop_if_exists index(:candidates, [:status_id, :display_order], name: :candidates_status_id_display_order_index)

    # Rename the table
    rename table(:statuses), to: table(:columns)

    # Rename the foreign key column
    rename table(:candidates), :status_id, to: :column_id

    # Create the new index with updated column name
    create unique_index(:candidates, [:column_id, :display_order], name: :candidates_column_id_display_order_index)
  end

  def down do
    # Drop the new index
    drop index(:candidates, [:column_id, :display_order], name: :candidates_column_id_display_order_index)

    # Rename the foreign key column back
    rename table(:candidates), :column_id, to: :status_id

    # Rename the table back
    rename table(:columns), to: table(:statuses)

    # Recreate the original index
    create unique_index(:candidates, [:status_id, :display_order], name: :candidates_status_id_display_order_index)
  end
end
