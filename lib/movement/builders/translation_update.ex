defmodule Movement.Builders.TranslationUpdate do
  @moduledoc false
  @behaviour Movement.Builder

  alias Movement.Mappers.Operation, as: OperationMapper

  @action "update"

  def build(
        %Movement.Context{assigns: %{text: text, translation: %{corrected_text: corrected_text, translated: true}}} =
          context
      )
      when text === corrected_text,
      do: context

  def build(%Movement.Context{assigns: %{translation: translation, text: text}, operations: operations} = context) do
    value_type = Movement.Mappers.ValueType.from_translation_new_value(translation, text)
    operation = OperationMapper.map(@action, translation, %{text: text, value_type: value_type})

    %{context | operations: Enum.concat(operations, [operation])}
  end
end
