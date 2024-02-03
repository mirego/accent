defmodule Langue.Formatter.SimpleJson do
  @moduledoc false
  use Langue.Formatter,
    id: "simple_json",
    display_name: "Simple JSON",
    extension: "json",
    parser: Langue.Formatter.SimpleJson.Parser,
    serializer: Langue.Formatter.SimpleJson.Serializer

  def placeholder_regex, do: Langue.Formatter.Json.placeholder_regex()
end
