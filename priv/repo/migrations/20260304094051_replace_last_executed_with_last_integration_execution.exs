defmodule Accent.Repo.Migrations.ReplaceLastExecutedWithLastIntegrationExecution do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:integrations) do
      add(:last_integration_execution_id, references(:integration_executions, type: :uuid, on_delete: :nilify_all))
      remove(:last_executed_at, :utc_datetime_usec)
      remove(:last_executed_by_user_id, references(:users, type: :uuid))
    end
  end
end
