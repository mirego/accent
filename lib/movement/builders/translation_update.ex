defmodule Movement.Builders.TranslationUpdate do
  @moduledoc false
  @behaviour Movement.Builder

  alias Movement.Builders.VersionCopyOnUpdate
  alias Movement.Mappers.Operation, as: OperationMapper
  alias Movement.Mappers.ValueType

  @action "update"

  def build(
        %Movement.Context{assigns: %{text: text, translation: %{corrected_text: corrected_text, translated: true}}} =
          context
      )
      when text === corrected_text,
      do: context

  def build(%Movement.Context{assigns: %{translation: translation, text: text}, operations: operations} = context) do
    value_type = ValueType.from_translation_new_value(translation, text)
    operation = OperationMapper.map(@action, translation, %{text: text, value_type: value_type})

    copy_version_operation = VersionCopyOnUpdate.maybe_copy_to_latest_version(translation, text, @action)

    %{context | operations: Enum.concat(operations, [operation] ++ List.wrap(copy_version_operation))}
  end
end
