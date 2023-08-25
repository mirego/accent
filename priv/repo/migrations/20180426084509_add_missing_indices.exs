defmodule Accent.Repo.Migrations.AddMissingIndices do
  @moduledoc false
  use Ecto.Migration

  def change do
    create(index(:auth_access_tokens, [:user_id], where: "revoked_at IS NULL"))

    create(index(:auth_providers, [:user_id]))

    create(index(:comments, [:user_id]))
    create(index(:comments, [:translation_id]))

    create(index(:documents, [:project_id]))

    create(index(:integrations, [:project_id]))
    create(index(:integrations, [:user_id]))

    create(index(:operations, [:translation_id]))
    create(index(:operations, [:revision_id]))
    create(index(:operations, [:project_id]))
    create(index(:operations, [:comment_id]))
    create(index(:operations, [:batch_operation_id]))
    create(index(:operations, [:rollbacked_operation_id]))
    create(index(:operations, [:user_id]))
    create(index(:operations, [:document_id]))
    create(index(:operations, [:version_id]))

    create(index(:projects, [:language_id]))

    create(index(:revisions, [:project_id]))
    create(index(:revisions, [:language_id]))
    create(index(:revisions, [:master_revision_id]))

    create(index(:translations, [:document_id]))
    create(index(:translations, [:version_id]))
    create(index(:translations, [:source_translation_id]))

    create(index(:versions, [:project_id]))
    create(index(:versions, [:user_id]))
  end
end
