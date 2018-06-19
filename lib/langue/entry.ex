defmodule Langue.Entry do
  defstruct key: nil, value: nil, comment: "", index: 1, value_type: "string", locked: false, plural: false

  @type t :: %__MODULE__{
          key: binary() | nil,
          value: binary() | nil,
          comment: binary() | nil,
          index: integer(),
          value_type: binary(),
          locked: boolean(),
          plural: boolean()
        }
end
