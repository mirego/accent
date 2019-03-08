defmodule Langue.Formatter.Strings do
  @behaviour Langue.Formatter

  alias Langue.Formatter.Strings.{Parser, Serializer}

  def name, do: "strings"
  def placeholder_regex, do: ~r/%(\d\$)?s/

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
