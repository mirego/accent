defmodule Langue.Formatter.Rails do
  @enabled Code.ensure_loaded?(:fast_yaml)

  if @enabled do
    use Langue.Formatter,
      id: "rails_yml",
      display_name: "Rails YAML",
      extension: "yml",
      parser: Langue.Formatter.Rails.Parser,
      serializer: Langue.Formatter.Rails.Serializer
  else
    use Langue.Formatter,
      id: "rails_yml",
      display_name: "Rails YAML",
      extension: "yml"
  end

  def enabled?, do: @enabled
  def placeholder_regex, do: ~r/%{[^}]*}/
end
