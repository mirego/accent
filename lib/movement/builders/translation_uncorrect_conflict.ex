defmodule Movement.Builders.TranslationUncorrectConflict do
  @behaviour Movement.Builder

  alias Movement.Mappers.Operation, as: OperationMapper

  @action "uncorrect_conflict"

  def build(context = %Movement.Context{assigns: %{translation: translation}, operations: operations}) do
    operation = OperationMapper.map(@action, translation, %{text: nil})

    %{context | operations: Enum.concat(operations, [operation])}
  end
end
