defmodule Accent.Repo.Migrations.CreateRevisions do
  use Ecto.Migration

  def change do
    create table(:revisions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :project_id, references(:projects, type: :uuid)
      add :language_id, references(:languages, type: :uuid)

      add :master, :boolean, [default: true]

      timestamps
    end

    alter table(:revisions) do
      add :master_revision_id, references(:revisions, type: :uuid)
    end
  end
end
