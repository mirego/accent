defmodule Langue.Formatter.SimpleJson do
  @behaviour Langue.Formatter

  alias Langue.Formatter.SimpleJson.{Parser, Serializer}

  def name, do: "simple_json"
  def placeholder_regex, do: ~r/{{[^}]*}}/

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
