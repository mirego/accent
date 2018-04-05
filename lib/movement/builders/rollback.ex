defmodule Movement.Builders.Rollback do
  @behaviour Movement.Builder

  alias Movement.Operation
  alias Accent.PreviousTranslation

  @action "rollback"

  # Batch operation
  def build(context = %Movement.Context{assigns: %{operation: operation = %{batch: true}}, operations: operations}) do
    new_operation = %Operation{
      action: @action,
      key: operation.key,
      batch: true,
      translation_id: operation.translation_id,
      revision_id: operation.revision_id,
      project_id: operation.project_id,
      document_id: operation.document_id,
      rollbacked_operation_id: operation.id
    }

    %{context | operations: Enum.concat(operations, [new_operation])}
  end

  # Translation operation
  def build(context = %Movement.Context{assigns: %{operation: operation}, operations: operations}) do
    new_operation = %Operation{
      action: @action,
      key: operation.translation.key,
      previous_translation: PreviousTranslation.from_translation(operation.translation),
      translation_id: operation.translation_id,
      revision_id: operation.revision_id,
      project_id: operation.project_id,
      document_id: operation.document_id,
      rollbacked_operation_id: operation.id
    }

    %{context | operations: Enum.concat(operations, [new_operation])}
  end
end
