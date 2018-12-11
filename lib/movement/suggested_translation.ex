defmodule Movement.SuggestedTranslation do
  @enforce_keys ~w(text)a
  defstruct ~w(text key file_comment file_index value_type revision_id plural locked interpolations)a
end
