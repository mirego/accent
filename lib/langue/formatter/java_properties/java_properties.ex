defmodule Langue.Formatter.JavaProperties do
  @behaviour Langue.Formatter

  alias Langue.Formatter.JavaProperties.{Parser, Serializer}

  def name, do: "java_properties"
  def placeholder_regex, do: ~r/\${[^}]*}/

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
