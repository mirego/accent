defmodule Movement.Operation do
  defstruct action: nil,
            key: nil,
            text: nil,
            file_comment: nil,
            file_index: 0,
            value_type: nil,
            plural: false,
            locked: false,
            batch: false,
            translation_id: nil,
            rollbacked_operation_id: nil,
            batch_operation_id: nil,
            revision_id: nil,
            version_id: nil,
            document_id: nil,
            project_id: nil,
            previous_translation: nil,
            placeholders: [],
            message_context: nil

  @type t :: %__MODULE__{}
end
