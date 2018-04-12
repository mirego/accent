defmodule Movement.Mappers.Operation do
  alias Accent.PreviousTranslation

  @spec map(binary, map, map) :: Movement.Operation.t()
  def map(action = "new", current_translation, suggested_translation) do
    %Movement.Operation{
      action: action,
      text: suggested_translation.text,
      key: suggested_translation.key,
      file_comment: suggested_translation.file_comment,
      file_index: suggested_translation.file_index,
      value_type: Map.get(suggested_translation, :value_type),
      revision_id: Map.get(suggested_translation, :revision_id),
      document_id: Map.get(suggested_translation, :document_id),
      version_id: Map.get(suggested_translation, :version_id),
      previous_translation: PreviousTranslation.from_translation(current_translation)
    }
  end

  def map(action, current_translation, suggested_translation) do
    %Movement.Operation{
      action: action,
      text: suggested_translation.text,
      key: Map.get(suggested_translation, :key, current_translation.key),
      file_comment: Map.get(suggested_translation, :file_comment, current_translation.file_comment),
      file_index: Map.get(suggested_translation, :file_index, current_translation.file_index),
      document_id: Map.get(suggested_translation, :document_id, current_translation.document_id),
      revision_id: Map.get(suggested_translation, :revision_id, current_translation.revision_id),
      version_id: Map.get(suggested_translation, :version_id, current_translation.version_id),
      value_type: Map.get(suggested_translation, :value_type, current_translation.value_type),
      translation_id: Map.get(current_translation, :id),
      previous_translation: PreviousTranslation.from_translation(current_translation)
    }
  end
end
