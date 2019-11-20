defmodule Langue.Entry do
  defstruct key: nil, master_value: nil, is_master: true, value: nil, comment: nil, index: 1, value_type: "string", locked: false, plural: false, placeholders: []

  @type t :: %__MODULE__{
          key: binary() | nil,
          value: binary() | nil,
          master_value: binary() | nil,
          is_master: boolean(),
          comment: binary() | nil,
          index: integer(),
          value_type: binary(),
          locked: boolean(),
          plural: boolean(),
          placeholders: list(binary)
        }
end
