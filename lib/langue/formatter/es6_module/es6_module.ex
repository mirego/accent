defmodule Langue.Formatter.Es6Module do
  alias Langue.Formatter.Es6Module.{Parser, Serializer}

  def name, do: "es_module"

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
