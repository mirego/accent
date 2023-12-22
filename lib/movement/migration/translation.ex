defmodule Movement.Migration.Translation do
  @moduledoc false
  @behaviour Movement.Migration

  import Movement.EctoMigrationHelper

  alias Accent.Operation
  alias Accent.Translation
  alias Ecto.UUID

  def call(:update_proposed, operation) do
    update(operation.translation, %{
      proposed_text: operation.text
    })
  end

  def call(:update, operation) do
    Accent.OperationBatcher.batch(operation)

    update(operation.translation, %{
      value_type: operation.value_type,
      translated: true,
      corrected_text: operation.text,
      conflicted_text: operation.previous_translation && operation.previous_translation.corrected_text,
      placeholders: operation.placeholders
    })
  end

  def call(:remove, operation) do
    update_all(operation.translation, %{removed: true})
  end

  def call(:renew, operation) do
    [
      update_all(operation, %{rollbacked: false}),
      update_all_dynamic(
        operation.translation,
        [:text, :text, :boolean, :boolean],
        [:proposed_text, :corrected_text, :conflicted, :removed],
        [operation.text, operation.text, true, false]
      )
    ]
  end

  def call(:new, operation) do
    id = UUID.generate()

    translation = %{
      id: id,
      key: operation.key,
      proposed_text: operation.text,
      corrected_text: operation.text,
      conflicted: is_nil(operation.version_id),
      value_type: operation.value_type,
      plural: operation.plural,
      locked: operation.locked,
      file_index: operation.file_index,
      file_comment: operation.file_comment,
      removed: operation.previous_translation && operation.previous_translation.removed,
      translated: is_nil(operation.translation_id),
      revision_id: operation.revision_id,
      document_id: operation.document_id,
      version_id: operation.version_id,
      source_translation_id: operation.translation_id,
      placeholders: operation.placeholders,
      inserted_at: {:placeholder, :now},
      updated_at: {:placeholder, :now}
    }

    [
      insert_all(Translation, translation),
      update_all_dynamic(operation, [:uuid], [:translation_id], [UUID.dump!(id)])
    ]
  end

  def call(:version_new, operation) do
    id = UUID.generate()

    translation = %{
      id: id,
      key: operation.key,
      proposed_text: operation.text,
      corrected_text: operation.text,
      translated: (operation.previous_translation && operation.previous_translation.translated) || false,
      conflicted: operation.previous_translation && operation.previous_translation.conflicted,
      value_type: operation.value_type,
      file_index: operation.file_index,
      file_comment: operation.file_comment,
      removed: operation.previous_translation && operation.previous_translation.removed,
      revision_id: operation.revision_id,
      document_id: operation.document_id,
      version_id: operation.version_id,
      source_translation_id: operation.translation_id,
      placeholders: operation.placeholders,
      inserted_at: {:placeholder, :now},
      updated_at: {:placeholder, :now}
    }

    version_operation =
      operation
      |> Map.take([
        :action,
        :key,
        :text,
        :value_type,
        :plural,
        :locked,
        :file_index,
        :file_comment,
        :removed,
        :revision_id,
        :user_id,
        :batch_operation_id,
        :document_id,
        :version_id,
        :project_id,
        :stats,
        :previous_translation
      ])
      |> Map.merge(%{
        translation_id: id,
        inserted_at: {:placeholder, :now},
        updated_at: {:placeholder, :now},
        action: "add_to_version"
      })

    [
      insert_all(Translation, translation),
      insert_all(Operation, version_operation)
    ]
  end

  def call(:restore, operation) do
    [
      update_all(operation, %{rollbacked: false}),
      update(operation.translation, Map.from_struct(operation.previous_translation))
    ]
  end
end
