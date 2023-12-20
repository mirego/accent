defmodule Movement.Builders.TranslationUncorrectConflict do
  @moduledoc false
  @behaviour Movement.Builder

  alias Movement.Mappers.Operation, as: OperationMapper

  @action "uncorrect_conflict"

  def build(%Movement.Context{assigns: %{translation: translation, text: text}, operations: operations} = context) do
    value_type = Movement.Mappers.ValueType.from_translation_new_value(translation, text)
    operation = OperationMapper.map(@action, translation, %{text: text, value_type: value_type})

    %{context | operations: Enum.concat(operations, [operation])}
  end
end
