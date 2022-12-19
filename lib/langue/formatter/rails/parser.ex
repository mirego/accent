if Langue.Formatter.Rails.enabled?() do
  defmodule Langue.Formatter.Rails.Parser do
    @behaviour Langue.Formatter.Parser

    alias Langue.Utils.{NestedParserHelper, Placeholders}

    def parse(%{render: render}) do
      {:ok, [content]} = :fast_yaml.decode(render)

      entries =
        content
        |> hd()
        |> elem(1)
        |> NestedParserHelper.parse()
        |> Placeholders.parse(Langue.Formatter.Rails.placeholder_regex())

      %Langue.Formatter.ParserResult{entries: entries}
    end
  end
end
