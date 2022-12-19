defmodule Langue.Formatter.JavaPropertiesXml do
  use Langue.Formatter,
    id: "java_properties_xml",
    display_name: "Java properties XML",
    extension: "xml",
    parser: Langue.Formatter.JavaPropertiesXml.Parser,
    serializer: Langue.Formatter.JavaPropertiesXml.Serializer

  def placeholder_regex, do: ~r/\${[^}]*}/
end
