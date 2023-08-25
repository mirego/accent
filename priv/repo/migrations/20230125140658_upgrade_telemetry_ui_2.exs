defmodule Accent.Repo.Migrations.UpgradeTelemetryUi2 do
  @moduledoc false
  use Ecto.Migration

  def up do
    TelemetryUI.Backend.EctoPostgres.Migrations.up(version: 3)
  end

  def down do
    TelemetryUI.Backend.EctoPostgres.Migrations.down(version: 2)
  end
end
