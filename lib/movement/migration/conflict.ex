defmodule Movement.Migration.Conflict do
  @moduledoc false
  @behaviour Movement.Migration

  import Movement.EctoMigrationHelper

  def call(:correct, operation) do
    Accent.OperationBatcher.batch(operation)

    update_all_dynamic(
      operation.translation,
      [:text, :text, :boolean, :boolean],
      [:corrected_text, :value_type, :conflicted, :translated],
      [operation.text, operation.value_type, false, true]
    )
  end

  def call(:uncorrect, operation) do
    conflicted_text =
      if operation.previous_translation do
        if operation.text === operation.previous_translation.corrected_text do
          operation.previous_translation.conflicted_text
        else
          operation.previous_translation.corrected_text
        end
      end

    update_all_dynamic(
      operation.translation,
      [:text, :text, :text, :boolean, :boolean],
      [:corrected_text, :conflicted_text, :value_type, :conflicted, :translated],
      [
        operation.text,
        conflicted_text,
        operation.value_type,
        true,
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
