defmodule Langue.Formatter.Json do
  use Langue.Formatter,
    id: "json",
    display_name: "JSON",
    extension: "json",
    parser: Langue.Formatter.Json.Parser,
    serializer: Langue.Formatter.Json.Serializer

  def placeholder_regex, do: ~r/{{[^}]*}}/
end
