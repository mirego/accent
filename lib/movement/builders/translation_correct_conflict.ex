defmodule Movement.Builders.TranslationCorrectConflict do
  @moduledoc false
  @behaviour Movement.Builder

  alias Movement.Builders.VersionCopyOnUpdate
  alias Movement.Mappers.Operation, as: OperationMapper

  @action "correct_conflict"

  def build(%Movement.Context{assigns: %{translation: translation, text: text}, operations: operations} = context) do
    value_type = Movement.Mappers.ValueType.from_translation_new_value(translation, text)
    operation = OperationMapper.map(@action, translation, %{text: text, value_type: value_type})

    copy_version_operation = VersionCopyOnUpdate.maybe_copy_to_latest_version(translation, text, @action)

    %{context | operations: Enum.concat(operations, [operation] ++ List.wrap(copy_version_operation))}
  end
end
