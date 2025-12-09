defmodule Accent.Repo.Migrations.AddLastUsedAtForAccessTokens do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:auth_access_tokens) do
      add(:last_used_at, :utc_datetime_usec)
    end
  end
end
