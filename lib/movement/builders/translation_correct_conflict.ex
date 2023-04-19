defmodule Movement.Builders.TranslationCorrectConflict do
  @behaviour Movement.Builder

  alias Movement.Mappers.Operation, as: OperationMapper

  @action "correct_conflict"

  def build(context = %Movement.Context{assigns: %{translation: translation, text: text}, operations: operations}) do
    value_type = Movement.Mappers.ValueType.from_translation_new_value(translation, text)
    operation = OperationMapper.map(@action, translation, %{text: text, value_type: value_type})

    %{context | operations: Enum.concat(operations, [operation])}
  end
end
