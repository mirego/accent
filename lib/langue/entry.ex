defmodule Langue.Entry do
  defstruct key: nil, value: nil, comment: nil, index: 1, value_type: "string", locked: false, plural: false, interpolations: []

  @type t :: %__MODULE__{
          key: binary() | nil,
          value: binary() | nil,
          comment: binary() | nil,
          index: integer(),
          value_type: binary(),
          locked: boolean(),
          plural: boolean(),
          interpolations: list(binary)
        }
end
