defmodule Langue.Formatter.LaravelPhp.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.Interpolations
  alias Langue.Utils.NestedParserHelper
  alias PhpAssocMap.Utils

  def parse(%{render: render}) do
    entries =
      render
      |> Utils.clean_up()
      |> PhpAssocMap.to_tuple()
      |> NestedParserHelper.parse()
      |> Interpolations.parse(Langue.Formatter.LaravelPhp.interpolation_regex())

    %Langue.Formatter.ParserResult{entries: entries}
  end
end
