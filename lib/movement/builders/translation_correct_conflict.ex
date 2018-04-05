defmodule Movement.Builders.TranslationCorrectConflict do
  @behaviour Movement.Builder

  alias Movement.Mappers.Operation, as: OperationMapper

  @action "correct_conflict"

  def build(context = %Movement.Context{assigns: %{translation: translation, text: text}, operations: operations}) do
    operation = OperationMapper.map(@action, translation, %{text: text})

    %{context | operations: Enum.concat(operations, [operation])}
  end
end
