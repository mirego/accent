defmodule Movement.SuggestedTranslation do
  @moduledoc false
  @enforce_keys ~w(text)a
  defstruct ~w(text key file_comment file_index value_type revision_id translation_id version_id plural locked placeholders machine_translations_enabled)a
end
