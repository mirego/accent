defmodule Langue.Formatter.SerializerResult do
  @type t :: struct

  @enforce_keys [:render]
  defstruct render: "", document: nil

  def empty, do: %__MODULE__{render: ""}
end
