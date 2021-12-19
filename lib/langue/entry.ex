defmodule Langue.Entry do
  @enforce_keys ~w(key value value_type)a
  defstruct id: nil,
            key: nil,
            master_value: nil,
            is_master: true,
            value: nil,
            comment: nil,
            index: 1,
            value_type: "string",
            locked: false,
            plural: false,
            placeholders: [],
            language_slug: nil

  @type t :: %__MODULE__{
          id: binary(),
          key: binary() | nil,
          value: binary() | nil,
          master_value: binary() | nil,
          is_master: boolean(),
          comment: binary() | nil,
          index: integer(),
          value_type: binary(),
          locked: boolean(),
          plural: boolean(),
          placeholders: list(binary),
          language_slug: String.t()
        }
end
