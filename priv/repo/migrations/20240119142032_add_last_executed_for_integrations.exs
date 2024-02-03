defmodule Accent.Repo.Migrations.AddLastExecutedForIntegrations do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:integrations) do
      add(:last_executed_at, :utc_datetime_usec)
      add(:last_executed_by_user_id, references(:users, type: :uuid))
    end
  end
end
