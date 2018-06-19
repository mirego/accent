defmodule Langue.Formatter.GoI18nJson do
  alias Langue.Formatter.GoI18nJson.{Parser, Serializer}

  def name, do: "go_i18n_json"

  defdelegate parse(map), to: Parser
  defdelegate serialize(map), to: Serializer
end
