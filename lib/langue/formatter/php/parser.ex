defmodule Langue.Formatter.Php.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.NestedParserHelper
  alias PhpAssocMap.Utils

  def parse(%{render: render}) do
    entries =
      render
      |> Utils.clean_up()
      |> PhpAssocMap.to_tuple()
      |> NestedParserHelper.parse()

    %Langue.Formatter.ParserResult{entries: entries}
  end
end
