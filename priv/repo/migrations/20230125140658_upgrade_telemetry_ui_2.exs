defmodule Accent.Repo.Migrations.UpgradeTelemetryUi2 do
  @moduledoc false
  use Ecto.Migration

  alias TelemetryUI.Backend.EctoPostgres.Migrations

  @disable_ddl_transaction true
  @disable_migration_lock true

  def up do
    Migrations.up(version: 3)
  end

  def down do
    Migrations.down(version: 2)
  end
end
