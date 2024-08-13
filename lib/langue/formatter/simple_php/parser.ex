defmodule Langue.Formatter.SimplePhp.Parser do
  @moduledoc false
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.Placeholders

  def parse(%{render: render}) do
    entries =
      render
      |> PhpAssocMap.to_tuple()
      |> Enum.with_index(1)
      |> Enum.map(fn {{key, value}, index} ->
        %Langue.Entry{
          key: key,
          value: value,
          index: index,
          value_type: Langue.ValueType.parse(value)
        }
      end)
      |> Placeholders.parse(Langue.Formatter.SimplePhp.placeholder_regex())

    %Langue.Formatter.ParserResult{entries: entries}
  end
end
