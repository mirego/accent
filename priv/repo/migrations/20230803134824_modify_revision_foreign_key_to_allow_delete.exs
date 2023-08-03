defmodule Accent.Repo.Migrations.ModifyRevisionForeignKeyToAllowDelete do
  use Ecto.Migration

  def change do
    execute("ALTER TABLE operations DROP CONSTRAINT operations_revision_id_fkey")

    alter table(:operations) do
      modify(:revision_id, references(:revisions, type: :uuid, on_delete: :delete_all), null: true)
    end

    execute("ALTER TABLE translations DROP CONSTRAINT translations_revision_id_fkey")
    execute("ALTER TABLE translations DROP CONSTRAINT translations_source_translation_id_fkey")

    alter table(:translations) do
      modify(:revision_id, references(:revisions, type: :uuid, on_delete: :delete_all), null: false)

      modify(
        :source_translation_id,
        references(:translations, type: :uuid, on_delete: :delete_all),
        null: true
      )
    end

    execute("ALTER TABLE comments DROP CONSTRAINT comments_translation_id_fkey")

    alter table(:comments) do
      modify(:translation_id, references(:translations, type: :uuid, on_delete: :delete_all), null: false)
    end

    execute("ALTER TABLE translation_comments_subscriptions DROP CONSTRAINT translation_comments_subscriptions_translation_id_fkey")

    alter table(:translation_comments_subscriptions) do
      modify(:translation_id, references(:translations, type: :uuid, on_delete: :delete_all), null: false)
    end
  end
end
