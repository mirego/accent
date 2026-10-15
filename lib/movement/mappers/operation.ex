defmodule Movement.Mappers.Operation do
  @moduledoc false
  alias Accent.PreviousTranslation
  alias Movement.SuggestedTranslation

  @spec map(binary, map, SuggestedTranslation.t() | Accent.Translation.t()) :: Movement.Operation.t()
  def map("new" = action, current_translation, %SuggestedTranslation{} = suggested_translation) do
    %Movement.Operation{
      action: action,
      text: suggested_translation.text,
      key: suggested_translation.key,
      file_comment: suggested_translation.file_comment,
      file_index: suggested_translation.file_index,
      value_type: suggested_translation.value_type,
      plural: suggested_translation.plural,
      locked: suggested_translation.locked,
      revision_id: suggested_translation.revision_id,
      document_id: suggested_translation.document_id,
      version_id: suggested_translation.version_id,
      translation_id: suggested_translation.translation_id,
      previous_translation: PreviousTranslation.from_translation(current_translation),
      machine_translations_enabled: suggested_translation.machine_translations_enabled,
      placeholders: suggested_translation.placeholders,
      versioned_translation_ids: suggested_translation.versioned_translation_ids,
      source_translation_id: suggested_translation.source_translation_id
    }
  end

  def map(action, current_translation, %SuggestedTranslation{} = suggested_translation) do
    %Movement.Operation{
      action: action,
      text: suggested_translation.text,
      key: suggested_translation.key,
      file_comment: suggested_translation.file_comment,
      file_index: suggested_translation.file_index,
      document_id: current_translation.document_id,
      revision_id: suggested_translation.revision_id,
      version_id: suggested_translation.version_id,
      value_type: suggested_translation.value_type,
      plural: suggested_translation.plural,
      locked: suggested_translation.locked,
      translation_id: Map.get(current_translation, :id),
      machine_translations_enabled: suggested_translation.machine_translations_enabled,
      previous_translation: PreviousTranslation.from_translation(current_translation),
      placeholders: suggested_translation.placeholders
    }
  end

  def map(action, current_translation, %Accent.Translation{} = removed_translation) do
    map_text(action, current_translation, removed_translation.text, removed_translation.value_type)
  end

  @spec map_text(binary, map, String.t() | nil) :: Movement.Operation.t()
  def map_text(action, current_translation, text) do
    map_text(action, current_translation, text, current_translation.value_type)
  end

  @spec map_text(binary, map, String.t() | nil, String.t()) :: Movement.Operation.t()
  def map_text(action, current_translation, text, value_type) do
    %Movement.Operation{
      action: action,
      text: text,
      key: current_translation.key,
      file_comment: current_translation.file_comment,
      file_index: current_translation.file_index,
      document_id: current_translation.document_id,
      revision_id: current_translation.revision_id,
      version_id: current_translation.version_id,
      value_type: value_type,
      plural: current_translation.plural,
      locked: current_translation.locked,
      translation_id: Map.get(current_translation, :id),
      machine_translations_enabled: false,
      previous_translation: PreviousTranslation.from_translation(current_translation),
      placeholders: current_translation.placeholders
    }
  end
end
