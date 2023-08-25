defmodule Accent.Repo.Migrations.CreateTranslationCommentsSubscriptions do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:translation_comments_subscriptions, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:user_id, references(:users, type: :uuid))
      add(:translation_id, references(:translations, type: :uuid))

      timestamps()
    end

    create(index(:translation_comments_subscriptions, [:user_id, :translation_id], unique: true))
  end
end
