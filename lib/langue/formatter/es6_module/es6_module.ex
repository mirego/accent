defmodule Langue.Formatter.Es6Module do
  @behaviour Langue.Formatter

  alias Langue.Formatter.Es6Module.{Parser, Serializer}

  def name, do: "es6_module"
  def placeholder_regex, do: ~r/{{[^}]*}}/

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
