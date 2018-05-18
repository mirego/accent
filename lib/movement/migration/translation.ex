defmodule Movement.Migration.Translation do
  @behaviour Movement.Migration

  import Movement.EctoMigrationHelper

  alias Accent.{Operation, Translation}

  def call(:update_proposed, operation) do
    operation.translation
    |> update(%{
      proposed_text: operation.text
    })
  end

  def call(:update, operation) do
    Accent.OperationBatcher.batch(operation)

    operation.translation
    |> update(%{
      value_type: operation.value_type,
      corrected_text: operation.text,
      conflicted_text: operation.previous_translation && operation.previous_translation.corrected_text,
      interpolations: operation.interpolations
    })
  end

  def call(:remove, operation) do
    update(operation.translation, %{removed: true})
  end

  def call(:renew, operation) do
    new_translation = %{
      proposed_text: operation.text,
      corrected_text: operation.text,
      conflicted: true,
      removed: false
    }

    update(operation, %{rollbacked: false})
    update(operation.translation, new_translation)
  end

  def call(:new, operation) do
    id = Ecto.UUID.generate()

    translation = %Translation{
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
      revision_id: operation.revision_id,
      document_id: operation.document_id,
      version_id: operation.version_id,
      interpolations: operation.interpolations
    }

    insert(translation)
    update(operation, %{translation_id: id})
  end

  def call(:version_new, operation) do
    id = Ecto.UUID.generate()

    translation = %Translation{
      id: id,
      key: operation.key,
      proposed_text: operation.text,
      corrected_text: operation.text,
      conflicted: false,
      value_type: operation.value_type,
      file_index: operation.file_index,
      file_comment: operation.file_comment,
      removed: operation.previous_translation && operation.previous_translation.removed,
      revision_id: operation.revision_id,
      document_id: operation.document_id,
      version_id: operation.version_id,
      source_translation_id: operation.translation_id,
      interpolations: operation.interpolations
    }

    version_operation = Operation.copy(operation, %{action: "add_to_version", translation_id: id})

    insert(translation)
    insert(version_operation)
  end

  def call(:restore, operation) do
    update(operation, %{rollbacked: false})
    update(operation.translation, Map.from_struct(operation.previous_translation))
  end
end
