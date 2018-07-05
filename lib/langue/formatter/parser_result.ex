defmodule Langue.Formatter.ParserResult do
  @type t :: struct

  @enforce_keys [:entries]
  defstruct entries: [], top_of_the_file_comment: "", header: "", language: nil

  def empty, do: %__MODULE__{entries: []}
end
