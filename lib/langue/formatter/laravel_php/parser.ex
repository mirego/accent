defmodule Langue.Formatter.LaravelPhp.Parser do
  @moduledoc false
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.NestedParserHelper
  alias Langue.Utils.Placeholders
  alias PhpAssocMap.Utils

  def parse(%{render: render}) do
    entries =
      render
      |> Utils.clean_up()
      |> PhpAssocMap.to_tuple()
      |> NestedParserHelper.parse()
      |> Placeholders.parse(Langue.Formatter.LaravelPhp.placeholder_regex())

    %Langue.Formatter.ParserResult{entries: entries}
  end
end
