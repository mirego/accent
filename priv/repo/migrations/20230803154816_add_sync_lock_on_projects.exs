defmodule Accent.Repo.Migrations.AddSyncLockOnProjects do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add(:sync_lock_version, :integer, default: 1)
    end
  end
end
