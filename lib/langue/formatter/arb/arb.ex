defmodule Langue.Formatter.ARB do
  @behaviour Langue.Formatter

  alias Langue.Formatter.ARB.{Parser, Serializer}

  def name, do: "arb"
  def placeholder_regex, do: ~r/{{[^}]*}}/

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
