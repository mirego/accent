defmodule Langue.Formatter.GoI18nJson do
  use Langue.Formatter,
    id: "go_i18n_json",
    display_name: "Go I18n JSON",
    extension: "json",
    parser: Langue.Formatter.GoI18nJson.Parser,
    serializer: Langue.Formatter.GoI18nJson.Serializer

  def placeholder_regex, do: ~r/{{\.[^}]*}}/
end
