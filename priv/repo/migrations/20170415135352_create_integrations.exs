defmodule Accent.Repo.Migrations.CreateIntegrations do
  use Ecto.Migration

  def change do
    create table(:integrations, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:service, :text, null: false)

      add(:events, {:array, :string}, null: false, default: [])
      add(:data, :json, null: false)

      add(:project_id, references(:projects, type: :uuid), null: false)
      add(:user_id, references(:users, type: :uuid), null: false)

      timestamps()
    end
  end
end
