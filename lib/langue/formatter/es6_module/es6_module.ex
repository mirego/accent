defmodule Langue.Formatter.Es6Module do
  use Langue.Formatter,
    id: "es6_module",
    display_name: "ES6 module",
    extension: "js",
    parser: Langue.Formatter.Es6Module.Parser,
    serializer: Langue.Formatter.Es6Module.Serializer

  def placeholder_regex, do: ~r/{{[^}]*}}/
end
