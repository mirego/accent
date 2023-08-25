defmodule Movement.Operation do
  @moduledoc false
  defstruct action: nil,
            key: nil,
            text: nil,
            file_comment: nil,
            file_index: 0,
            value_type: "string",
            plural: false,
            locked: false,
            batch: false,
            translation_id: nil,
            rollbacked_operation_id: nil,
            batch_operation_id: nil,
            revision_id: nil,
            version_id: nil,
            document_id: nil,
            user_id: nil,
            inserted_at: nil,
            updated_at: nil,
            project_id: nil,
            previous_translation: nil,
            placeholders: [],
            options: [],
            machine_translated: false,
            machine_translations_enabled: false

  @type t :: %__MODULE__{}
end
