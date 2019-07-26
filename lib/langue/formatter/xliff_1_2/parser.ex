defmodule Langue.Formatter.XLIFF12.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Entry
  alias Langue.Utils.Placeholders

  require IEx

  def parse(%{render: render}) do
    render
    |> :erlsom.simple_form([{:nameFun, fn(name, _namespace, _prefix) -> name end}])
    |> case do
      {:ok, {'file', _attributes, _body} = file, _} ->
        %Langue.Formatter.ParserResult{entries: process_file(file)}
      {:ok, {'xliff', _attributes, body}, _} ->
        %Langue.Formatter.ParserResult{entries: process_xliff(body, [])}
      _ ->
        Langue.Formatter.ParserResult.empty()
    end
  end

  defp generate_entry(filename, key, value, source, comment, index) do
    key = IO.chardata_to_string(key)
    value = IO.chardata_to_string(value)
    source = IO.chardata_to_string(source)
    comment = case comment do
      nil -> nil
      _ -> IO.chardata_to_string(comment)
    end

    %Entry{
      value: value,
      master_value: source,
      value_type: Langue.ValueType.parse(value),
      comment: comment,
      key: key,
      index: index,
      file: filename
    }
  end

  defp parse_line(filename, {{'trans-unit', [{'id', key}], [{'source', [], [source]}, {'target', [], [value]}]}, index}), do: generate_entry(filename, key, value, source, nil, index)
  defp parse_line(filename, {{'trans-unit', [{'id', key}], [{'source', [], [source]}, {'target', [], [value]}, {'note', [], [note]}]}, index}), do: generate_entry(filename, key, value, source, note, index)

  defp parse_line(_, _), do: nil

  defp fetch_filename(nil), do: nil
  defp fetch_filename(attributes) do
    {'original', file} =  Enum.find(attributes, {'original', nil}, fn x -> case x do
      {'original', _} -> true
      _ -> false
    end
    end)

    file
  end


  defp process_file_entry(body, attributes) do
    filename = fetch_filename(attributes)
    entries =
      body
      |> Enum.with_index(1)
      |> Enum.map(fn x -> parse_line(filename, x) end)
      |> Enum.reject(&is_nil/1)
      |> Placeholders.parse(Langue.Formatter.XLIFF12.placeholder_regex())

    entries
  end

  defp process_file({'file', attributes, [{'body', _, body}]}), do: process_file_entry(body, attributes)
  defp process_file({'file', attributes, [{'header', _, _header}, {'body', _, body}]}), do: process_file_entry(body, attributes)

  defp process_xliff([file | rest], accumulator) do
    entries = process_file(file)

    process_xliff(rest, accumulator ++ entries)
  end

  defp process_xliff([], accumulator) do
    accumulator
  end

end
