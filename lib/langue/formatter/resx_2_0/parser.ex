defmodule Langue.Formatter.Resx20.Parser do
  @behaviour Langue.Formatter.Parser

  def parse(%{render: render}) do
    entries =
      render
      |> :erlsom.simple_form()
      |> case do
        {:ok, {'root', [], nodes}, _} ->
          Enum.filter(nodes, &match?({'data', _, _}, &1))
      end
      |> Enum.reduce([], fn {_, attributes, body}, acc ->
        key = List.keyfind(attributes, 'name', 0)
        value = List.keyfind(body, 'value', 0)

        case to_entry(key, value) do
          nil -> acc
          entry -> [entry | acc]
        end
      end)
      |> Enum.reverse()
      |> Enum.with_index(1)
      |> Enum.map(fn {entry, index} -> %{entry | index: index} end)

    %Langue.Formatter.ParserResult{entries: entries}
  end

  defp to_entry({'name', key}, {'value', _, [value]}) do
    %Langue.Entry{
      key: to_string(key),
      value: to_string(value),
      value_type: Langue.ValueType.parse(to_string(value))
    }
  end
end
