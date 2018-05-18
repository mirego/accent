defmodule Langue.Formatter.Rails.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.{Interpolations, NestedParserHelper}

  def parse(%{render: render}) do
    {:ok, [content]} = :fast_yaml.decode(render)

    entries =
      content
      |> Enum.at(0)
      |> elem(1)
      |> NestedParserHelper.parse()
      |> Interpolations.parse(Langue.Formatter.Rails.interpolation_regex())

    %Langue.Formatter.ParserResult{entries: entries}
  end
end
