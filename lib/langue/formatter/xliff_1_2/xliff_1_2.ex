defmodule Langue.Formatter.XLIFF12 do
  @behaviour Langue.Formatter

  alias Langue.Formatter.XLIFF12.{Parser, Serializer}

  def name, do: "xliff_1_2"
  def placeholder_regex, do: :not_supported

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
