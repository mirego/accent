defmodule Movement.SuggestedTranslation do
  @moduledoc false
  @enforce_keys ~w(text)a

  defstruct text: nil,
            key: nil,
            file_comment: nil,
            file_index: nil,
            value_type: nil,
            revision_id: nil,
            translation_id: nil,
            version_id: nil,
            plural: nil,
            locked: nil,
            placeholders: nil,
            machine_translations_enabled: nil,
            versioned_translation_ids: []
end
