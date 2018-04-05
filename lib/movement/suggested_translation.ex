defmodule Movement.SuggestedTranslation do
  @enforce_keys ~w(text key)a
  defstruct ~w(text key file_comment file_index value_type revision_id)a
end
