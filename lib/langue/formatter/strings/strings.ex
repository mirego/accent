defmodule Langue.Formatter.Strings do
  alias Langue.Formatter.Strings.{Parser, Serializer}

  def name, do: "strings"

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
