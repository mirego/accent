defmodule Movement.Builders.TranslationUncorrectConflict do
  @moduledoc false
  @behaviour Movement.Builder

  alias Movement.Mappers.Operation, as: OperationMapper

  @action "uncorrect_conflict"

  def build(%Movement.Context{assigns: %{translation: translation}, operations: operations} = context) do
    operation = OperationMapper.map(@action, translation, %{text: nil})

    %{context | operations: Enum.concat(operations, [operation])}
  end
end
