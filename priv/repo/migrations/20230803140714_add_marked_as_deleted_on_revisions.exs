defmodule Accent.Repo.Migrations.AddMarkedAsDeletedOnRevisions do
  use Ecto.Migration

  def change do
    alter table(:revisions) do
      add(:marked_as_deleted, :boolean)
    end

    execute("UPDATE revisions SET marked_as_deleted = FALSE")

    alter table(:revisions) do
      modify(:marked_as_deleted, :boolean, null: false, default: false)
    end
  end
end
