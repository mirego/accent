defmodule Langue.Formatter.JavaProperties do
  use Langue.Formatter,
    id: "java_properties",
    display_name: "Java properties",
    extension: "properties",
    parser: Langue.Formatter.JavaProperties.Parser,
    serializer: Langue.Formatter.JavaProperties.Serializer

  def placeholder_regex, do: ~r/\${[^}]*}/
end
