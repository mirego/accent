defmodule Langue.Formatter.Json do
  @behaviour Langue.Formatter

  alias Langue.Formatter.Json.{Parser, Serializer}

  def name, do: "json"
  def placeholder_regex, do: ~r/{{[^}]*}}/

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
