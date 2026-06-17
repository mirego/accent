defmodule Langue.Formatter.RailsYml do
  @moduledoc false
  use Langue.Formatter,
    id: "rails_yml",
    display_name: "Rails YAML",
    extension: "yml",
    parser: Langue.Formatter.RailsYml.Parser,
    serializer: Langue.Formatter.RailsYml.Serializer

  def placeholder_regex, do: ~r/%{[^}]*}/
end
