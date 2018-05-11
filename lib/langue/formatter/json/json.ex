defmodule Langue.Formatter.Json do
  alias Langue.Formatter.Json.{Parser, Serializer}

  def name, do: "json"

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
