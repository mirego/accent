defmodule Accent.Repo.Migrations.AddLastSyncedAtToProject do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add(:last_synced_at, :utc_datetime)
    end
  end
end
