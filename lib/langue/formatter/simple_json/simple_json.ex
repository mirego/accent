defmodule Langue.Formatter.SimpleJson do
  alias Langue.Formatter.SimpleJson.{Parser, Serializer}

  def name, do: "simple_json"

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
