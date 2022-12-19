defmodule Langue.Formatter.Rails do
  use Langue.Formatter,
    id: "rails_yml",
    display_name: "Rails YAML",
    extension: "yml"

  def enabled?, do: Code.ensure_loaded?(:fast_yaml)
  def placeholder_regex, do: ~r/%{[^}]*}/
end
