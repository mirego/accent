defmodule Accent.Repo.Migrations.AddGlobalAccessTokens do
  use Ecto.Migration

  import Ecto.Query

  def up do
    alter table(:auth_access_tokens) do
      add(:global, :boolean, default: false, null: false)
    end

    create(unique_index(:auth_access_tokens, [:user_id, :global], where: "revoked_at::timestamp IS NULL AND global = true"))

    flush()

    for user_id <- Accent.Repo.all(from(users in Accent.User, select: users.id, where: [bot: false])) do
      Accent.Repo.insert!(%Accent.AccessToken{
        user_id: user_id,
        global: true,
        token: Accent.Utils.SecureRandom.urlsafe_base64(70)
      })
    end
  end

  def down do
    alter table(:auth_access_tokens) do
      remove(:global)
    end

    drop(unique_index(:auth_access_tokens, [:user_id, :global], name: "auth_access_tokens_user_id_global_index"))
  end
end
