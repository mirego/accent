defmodule Langue.Formatter.Strings do
  use Langue.Formatter,
    id: "strings",
    display_name: "Apple .strings",
    extension: "strings",
    parser: Langue.Formatter.Strings.Parser,
    serializer: Langue.Formatter.Strings.Serializer

  def placeholder_regex, do: ~r/%(\d\$)?s/
end
