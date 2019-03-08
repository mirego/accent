defmodule Accent.Repo.Migrations.CreateVersions do
  use Ecto.Migration

  def change do
    create table(:versions, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, null: false)
      add(:tag, :string, null: false)

      add(:project_id, references(:projects, type: :uuid), null: false)
      add(:user_id, references(:users, type: :uuid), null: false)

      timestamps()
    end

    create(index(:versions, [:tag, :project_id], unique: true))

    alter table(:operations) do
      add(:version_id, references(:versions, type: :uuid))
    end

    alter table(:translations) do
      add(:version_id, references(:versions, type: :uuid))
    end
  end
end
