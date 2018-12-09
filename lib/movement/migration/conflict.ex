defmodule Movement.Migration.Conflict do
  @behaviour Movement.Migration

  import Movement.EctoMigrationHelper

  def call(:correct, operation) do
    Accent.OperationBatcher.batch(operation)

    update(operation.translation, %{
      corrected_text: operation.text,
      conflicted: false
    })
  end

  def call(:uncorrect, operation) do
    update(operation.translation, %{
      conflicted_text: operation.previous_translation && operation.previous_translation.conflicted_text,
      conflicted: true
    })
  end

  def call(:on_corrected, operation) do
    update(operation.translation, %{
      value_type: operation.value_type,
      file_comment: operation.file_comment,
      file_index: operation.file_index,
      proposed_text: operation.text,
      corrected_text: operation.text,
      conflicted_text: operation.previous_translation && operation.previous_translation.corrected_text,
      conflicted: true
    })
  end

  def call(:on_slave, operation) do
    update(operation.translation, %{
      value_type: operation.value_type,
      file_comment: operation.file_comment,
      file_index: operation.file_index,
      corrected_text: operation.text,
      conflicted_text: operation.previous_translation && operation.previous_translation.conflicted_text,
      conflicted: true
    })
  end

  def call(:on_proposed, operation) do
    update(operation.translation, %{
      value_type: operation.value_type,
      file_comment: operation.file_comment,
      file_index: operation.file_index,
      proposed_text: operation.text,
      corrected_text: operation.text,
      conflicted_text: operation.previous_translation && operation.previous_translation.corrected_text,
      conflicted: true
    })
  end
end
