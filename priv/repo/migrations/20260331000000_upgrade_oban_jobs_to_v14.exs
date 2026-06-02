defmodule Accent.Repo.Migrations.UpgradeObanJobsToV14 do
  @moduledoc false
  use Ecto.Migration

  def up do
    Oban.Migrations.up(version: 14)
  end

  def down do
    Oban.Migrations.down(version: 13)
  end
end
