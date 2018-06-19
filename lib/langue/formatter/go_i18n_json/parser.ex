defmodule Langue.Formatter.GoI18nJson.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Entry

  def parse(%{render: render}) do
    entries =
      render
      |> :jiffy.decode()
      |> Enum.flat_map(&parse_element/1)
      |> Enum.with_index(1)
      |> Enum.map(fn {entry, index} -> %{entry | index: index} end)

    %Langue.Formatter.ParserResult{entries: entries}
  end

  defp parse_element({[{"id", key}, {"translation", {plurals}}]}) do
    Enum.map(plurals, fn {plural_key, plural_value} ->
      entry = fetch_entry(key <> "." <> plural_key, plural_value)
      %{entry | plural: true}
    end)
  end

  defp parse_element({[{"id", key}, {"translation", value}]}) do
    [fetch_entry(key, value)]
  end

  defp fetch_entry(key, value) do
    %Entry{
      key: key,
      value: to_string(value),
      value_type: Langue.ValueType.parse(value)
    }
  end
end
