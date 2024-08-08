defmodule Langue.Formatter.Resx20.Parser do
  @moduledoc false
  @behaviour Langue.Formatter.Parser

  def parse(%{render: render}) do
    entries =
      render
      |> :erlsom.simple_form()
      |> case do
        {:ok, {~c"root", [], nodes}, _} ->
          Enum.filter(nodes, &match?({~c"data", _, _}, &1))
      end
      |> Enum.flat_map(fn {_, attributes, body} ->
        key = List.keyfind(attributes, ~c"name", 0)
        value = List.keyfind(body, ~c"value", 0)
        List.wrap(to_entry(key, value))
      end)
      |> Enum.with_index(1)
      |> Enum.map(fn {entry, index} -> %{entry | index: index} end)

    %Langue.Formatter.ParserResult{entries: entries}
  end

  defp to_entry({~c"name", key}, {~c"value", _, [value]}) do
    %Langue.Entry{
      key: to_string(key),
      value: to_string(value),
      value_type: Langue.ValueType.parse(to_string(value))
    }
  end
end
