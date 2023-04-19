defmodule Movement.Migration.Conflict do
  @behaviour Movement.Migration

  import Movement.EctoMigrationHelper

  def call(:correct, operation) do
    Accent.OperationBatcher.batch(operation)

    update_all_dynamic(
      operation.translation,
      [:text, :text, :boolean],
      [:corrected_text, :value_type, :conflicted],
      [operation.text, operation.value_type, false]
    )
  end

  def call(:uncorrect, operation) do
    update_all_dynamic(
      operation.translation,
      [:text, :text, :boolean],
      [:conflicted_text, :value_type, :conflicted],
      [
        operation.previous_translation && operation.previous_translation.conflicted_text,
        operation.previous_translation && operation.previous_translation.value_type,
        true
      ]
    )
  end

  def call(:on_corrected, operation) do
    update(operation.translation, %{
      value_type: operation.value_type,
      file_comment: operation.file_comment,
      file_index: operation.file_index,
      proposed_text: operation.text,
      corrected_text: operation.text,
      conflicted_text: operation.previous_translation && operation.previous_translation.corrected_text,
      conflicted: true,
      placeholders: operation.placeholders
    })
  end

  def call(:on_slave, operation) do
    update(operation.translation, %{
      value_type: operation.value_type,
      file_comment: operation.file_comment,
      file_index: operation.file_index,
      corrected_text: operation.text,
      conflicted_text: operation.previous_translation && operation.previous_translation.conflicted_text,
      conflicted: true,
      placeholders: operation.placeholders
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
      conflicted: if("correct" in operation.options, do: false, else: true),
      placeholders: operation.placeholders
    })
  end
end
