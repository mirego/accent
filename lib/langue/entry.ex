defmodule Langue.Entry do
  defstruct key: nil, master_value: nil, value: nil, comment: nil, index: 1, value_type: "string", locked: false, plural: false, placeholders: [], context: nil

  @type t :: %__MODULE__{
          key: binary() | nil,
          value: binary() | nil,
          comment: binary() | nil,
          index: integer(),
          value_type: binary(),
          locked: boolean(),
          plural: boolean(),
          placeholders: list(binary),
          context: binary() | nil
        }
end
