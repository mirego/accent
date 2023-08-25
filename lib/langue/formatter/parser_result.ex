defmodule Langue.Formatter.ParserResult do
  @moduledoc false
  @type t :: struct

  @enforce_keys [:entries]
  defstruct entries: [], document: nil, language: nil

  def empty, do: %__MODULE__{entries: []}
end
