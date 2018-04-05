defmodule Langue.Formatter.SerializerResult do
  @type t :: struct

  @enforce_keys [:render]
  defstruct render: ""

  def empty, do: %__MODULE__{render: ""}
end
