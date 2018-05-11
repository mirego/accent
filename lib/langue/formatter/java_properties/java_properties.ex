defmodule Langue.Formatter.JavaProperties do
  alias Langue.Formatter.JavaProperties.{Parser, Serializer}

  def name, do: "java_properties"

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
