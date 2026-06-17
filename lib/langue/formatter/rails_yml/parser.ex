defmodule Langue.Formatter.RailsYml.Parser do
  @moduledoc false
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.NestedParserHelper
  alias Langue.Utils.Placeholders

  def parse(%{render: render}) do
    entries =
      render
      |> parse_yaml()
      |> Placeholders.parse(Langue.Formatter.RailsYml.placeholder_regex())

    %Langue.Formatter.ParserResult{entries: entries}
  end

  defp parse_yaml(render) do
    case :yamerl_constr.string(render, [:str_node_as_binary]) do
      [[{_locale, body} | _] | _] when is_list(body) ->
        body
        |> NestedParserHelper.parse()
        |> Enum.uniq_by(& &1.key)

      _other ->
        []
    end
  end
end
