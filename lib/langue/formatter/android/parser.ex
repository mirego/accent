defmodule Langue.Formatter.Android.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Entry

  def name, do: "android_xml"

  def parse(%{render: render}) do
    case :mochiweb_html.parse(render) do
      {"resources", _options, strings} ->
        entries =
          strings
          |> Enum.reduce(%{comment: [], entries: [], index: 1}, &parse_line(&1, &2))
          |> Map.get(:entries)

        %Langue.Formatter.ParserResult{entries: entries}

      _ ->
        Langue.Formatter.ParserResult.empty()
    end
  end

  # Simple string element, key => value
  defp parse_line({"string", attributes, [value]}, acc) do
    [key] = for {k, v} <- attributes, k == "name", do: v

    acc
    |> Map.put(
      :entries,
      Enum.concat(acc.entries, [
        %Entry{
          value: sanitize_value_to_string(value),
          key: key,
          index: acc.index,
          comment: Enum.join(acc.comment, "\n")
        }
      ])
    )
    |> Map.put(:comment, [])
    |> Map.put(:index, acc.index + 1)
  end

  defp parse_line({"string", attributes, []}, acc) do
    [key] = for {k, v} <- attributes, k == "name", do: v

    acc
    |> Map.put(
      :entries,
      Enum.concat(acc.entries, [
        %Entry{
          value: sanitize_value_to_string(""),
          value_type: "empty",
          key: key,
          index: acc.index,
          comment: Enum.join(acc.comment, "\n")
        }
      ])
    )
    |> Map.put(:comment, [])
    |> Map.put(:index, acc.index + 1)
  end

  # string-array element contains sub elements which are identified by index
  defp parse_line({"string-array", attributes, items}, acc) do
    [key] = for {k, v} <- attributes, k == "name", do: v

    items
    |> Enum.with_index(0)
    |> Enum.reduce(acc, &parse_item_line(&1, &2, key))
  end

  # Comments are only appended in the comments key of the accumulator
  defp parse_line({:comment, comment}, acc) do
    acc
    |> Map.put(:comment, Enum.concat(acc.comment, [comment]))
  end

  # Unsupported elements are simply ignored
  defp parse_line(_, acc), do: acc

  # Item contained in a entry with a value_type array
  defp parse_item_line({{"item", _attributes, [value]}, index}, acc, key) do
    acc
    |> Map.put(
      :entries,
      Enum.concat(acc.entries, [
        %Entry{
          key: "#{key}.__KEY__#{index}",
          value: sanitize_value_to_string(value),
          index: acc.index,
          comment: Enum.join(acc.comment, "\n"),
          value_type: "array"
        }
      ])
    )
    |> Map.put(:comment, [])
    |> Map.put(:index, acc.index + 1)
  end

  defp sanitize_value_to_string(value) do
    value
    |> String.replace("%s", "%@")
    |> String.replace(~r/%(\d)\$s/, "%\\g{1}$@")
    |> String.replace("&amp;", "&")
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
    |> String.replace("\\'", "'")
  end
end
