defmodule Accent.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:path, :string)
      add(:format, :string)

      add(:project_id, references(:projects, type: :uuid))

      timestamps()
    end

    create(index(:documents, [:path, :format, :project_id], unique: true))

    alter table(:translations) do
      remove(:file_path)

      add(:document_id, references(:documents, type: :uuid))
    end

    alter table(:operations) do
      remove(:file_path)

      add(:document_id, references(:documents, type: :uuid))
    end
  end
end
