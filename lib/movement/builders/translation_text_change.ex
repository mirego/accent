defmodule Movement.Builders.TranslationTextChange do
  @moduledoc false

  alias Movement.Builders.VersionCopyOnUpdate
  alias Movement.Mappers.Operation, as: OperationMapper
  alias Movement.Mappers.ValueType

  @spec build(Movement.Context.t(), String.t()) :: Movement.Context.t()
  def build(
        %Movement.Context{assigns: %{translation: translation, text: text}, operations: operations} = context,
        action
      ) do
    value_type = ValueType.from_translation_new_value(translation, text)
    operation = OperationMapper.map_text(action, translation, text, value_type)
    copy_version_operation = VersionCopyOnUpdate.maybe_copy_to_latest_version(translation, text, action)

    %{context | operations: [operation | List.wrap(copy_version_operation)] ++ operations}
  end
end
