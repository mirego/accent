defmodule Langue.Formatter.JavaPropertiesXml do
  @behaviour Langue.Formatter

  alias Langue.Formatter.JavaPropertiesXml.{Parser, Serializer}

  def name, do: "java_properties_xml"
  def placeholder_regex, do: ~r/\${[^}]*}/

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
