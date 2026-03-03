defmodule Accent.Repo.Migrations.AddIntegrationExecutions do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:integration_executions, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:integration_id, references(:integrations, type: :uuid), null: false)
      add(:version_id, references(:versions, type: :uuid))
      add(:user_id, references(:users, type: :uuid), null: false)
      add(:state, :string, null: false, default: "success")
      add(:data, :map, default: %{})
      add(:results, :map, default: %{})

      timestamps()
    end

    create(index(:integration_executions, [:integration_id]))
    create(index(:integration_executions, [:version_id]))
  end
end
