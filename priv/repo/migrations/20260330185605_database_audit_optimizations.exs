defmodule Accent.Repo.Migrations.DatabaseAuditOptimizations do
  @moduledoc false
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true

  def up do
    # Partial index for the stats hot path (non-removed, non-locked, no-version translations)
    create(
      index(:translations, [:revision_id],
        where: "removed = false AND locked = false AND version_id IS NULL",
        name: :translations_revision_id_active_index,
        concurrently: true
      )
    )

    # Document-scoped stats composite index
    create(
      index(:translations, [:document_id, :revision_id],
        where: "removed = false AND locked = false AND version_id IS NULL",
        name: :translations_document_revision_active_index,
        concurrently: true
      )
    )

    # Grouped queries by version/document/key
    create(
      index(:translations, [:version_id, :document_id, :key],
        where: "removed = false",
        name: :translations_grouped_key_index,
        concurrently: true
      )
    )

    # Faster activity/sync queries (last sync per project+action)
    create(
      index(:operations, [:project_id, :action, "inserted_at DESC"],
        name: :operations_project_action_inserted_index,
        concurrently: true
      )
    )

    # Faster operation lists ordered by inserted_at
    create(
      index(:operations, [:revision_id, "inserted_at DESC"],
        name: :operations_revision_inserted_index,
        concurrently: true
      )
    )

    # Partial index for non-batch operations (activity feed)
    create(
      index(:operations, [:project_id],
        where: "batch_operation_id IS NULL AND batch = false",
        name: :operations_non_batch_index,
        concurrently: true
      )
    )

    # Collaborators by project_id (project deletion, listing)
    create(index(:collaborators, [:project_id], concurrently: true))

    # Rate-limiting lookups by assigner
    create(index(:collaborators, [:assigner_id, :inserted_at], concurrently: true))

    # Hook outbounds / integration scope by project+service
    create(index(:integrations, [:project_id, :service], concurrently: true))

    # Revision listing ordered by master DESC
    create(
      index(:revisions, [:project_id, "master DESC"],
        name: :revisions_project_master_index,
        concurrently: true
      )
    )

    # DISTINCT ON (version_id, integration_id) ORDER BY inserted_at DESC
    create(
      index(:integration_executions, [:version_id, :integration_id, "inserted_at DESC"],
        name: :integration_executions_version_integration_inserted_index,
        concurrently: true
      )
    )

    # Drop redundant revisions(project_id) — subsumed by unique (project_id, language_id)
    drop_if_exists(index(:revisions, [:project_id], name: :revisions_project_id_index, concurrently: true))
  end

  def down do
    create(index(:revisions, [:project_id], concurrently: true))

    drop_if_exists(
      index(:integration_executions, [],
        name: :integration_executions_version_integration_inserted_index,
        concurrently: true
      )
    )

    drop_if_exists(index(:revisions, [], name: :revisions_project_master_index, concurrently: true))
    drop_if_exists(index(:integrations, [:project_id, :service], concurrently: true))
    drop_if_exists(index(:collaborators, [:assigner_id, :inserted_at], concurrently: true))
    drop_if_exists(index(:collaborators, [:project_id], concurrently: true))
    drop_if_exists(index(:operations, [], name: :operations_non_batch_index, concurrently: true))
    drop_if_exists(index(:operations, [], name: :operations_revision_inserted_index, concurrently: true))
    drop_if_exists(index(:operations, [], name: :operations_project_action_inserted_index, concurrently: true))
    drop_if_exists(index(:translations, [], name: :translations_grouped_key_index, concurrently: true))
    drop_if_exists(index(:translations, [], name: :translations_document_revision_active_index, concurrently: true))
    drop_if_exists(index(:translations, [], name: :translations_revision_id_active_index, concurrently: true))
  end
end
