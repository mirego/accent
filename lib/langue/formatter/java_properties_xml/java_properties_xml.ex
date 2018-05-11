defmodule Langue.Formatter.JavaPropertiesXml do
  alias Langue.Formatter.JavaPropertiesXml.{Parser, Serializer}

  def name, do: "java_properties_xml"

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
