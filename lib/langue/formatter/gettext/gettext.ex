defmodule Langue.Formatter.Gettext do
  use Langue.Formatter,
    id: "gettext",
    display_name: "Gettext",
    extension: "po",
    parser: Langue.Formatter.Gettext.Parser,
    serializer: Langue.Formatter.Gettext.Serializer

  def placeholder_regex, do: ~r/%{[^}]*}/
end
