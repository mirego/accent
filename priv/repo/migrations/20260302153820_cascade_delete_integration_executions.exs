defmodule Accent.Repo.Migrations.CascadeDeleteIntegrationExecutions do
  @moduledoc false
  use Ecto.Migration

  def change do
    drop(constraint(:integration_executions, "integration_executions_integration_id_fkey"))

    alter table(:integration_executions) do
      modify(:integration_id, references(:integrations, type: :uuid, on_delete: :delete_all), null: false)
    end
  end
end
