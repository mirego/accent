defmodule Langue.Formatter.XLIFF12.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Entry
  alias Langue.Utils.Placeholders

  def parse(%{render: render}) do
    render
    |> :erlsom.simple_form()
    |> case do
      {:ok, {'file', _attributes, [{'body', _, body}]}, _} ->
        entries =
          body
          |> Enum.with_index(1)
          |> Enum.map(&parse_line/1)
          |> Enum.reject(&is_nil/1)
          |> Placeholders.parse(Langue.Formatter.XLIFF12.placeholder_regex())

        %Langue.Formatter.ParserResult{entries: entries}

      _ ->
        Langue.Formatter.ParserResult.empty()
    end
  end

  defp parse_line({{'trans-unit', [{'id', key}], [{'source', _, source}, {'target', _, value}]}, index}) do
    value =
      case value do
        [value] -> IO.chardata_to_string(value)
        _ -> ""
      end

    source =
      case source do
        [source] -> IO.chardata_to_string(source)
        _ -> ""
      end

    %Entry{
      value: value,
      master_value: source,
      value_type: Langue.ValueType.parse(value),
      key: IO.chardata_to_string(key),
      index: index
    }
  end

  defp parse_line(_), do: nil
end
