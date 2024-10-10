defmodule Langue.Formatter.Android.Parser do
  @moduledoc false
  @behaviour Langue.Formatter.Parser

  alias Langue.Entry
  alias Langue.Formatter.ParserResult
  alias Langue.Utils.Placeholders

  def parse(%{render: render}) do
    case :mochiweb_html.parse(render) do
      {"resources", _options, strings} ->
        entries =
          strings
          |> Enum.reduce(%{comment: [], entries: [], index: 1}, &parse_line(&1, &2))
          |> Map.get(:entries)
          |> Placeholders.parse(Langue.Formatter.Android.placeholder_regex())

        %ParserResult{entries: entries}

      _ ->
        ParserResult.empty()
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
          value_type: Langue.ValueType.parse(value),
          key: key,
          index: acc.index,
          comment: serialize_comment(acc.comment)
        }
      ])
    )
    |> Map.put(:comment, [])
    |> Map.put(:index, acc.index + 1)
  end

  defp parse_line({"string", attributes, []}, acc), do: parse_line({"string", attributes, [""]}, acc)

  # string-array element contains sub elements which are identified by index
  defp parse_line({"string-array", attributes, items}, acc) do
    [key] = for {k, v} <- attributes, k == "name", do: v

    items
    |> Enum.with_index(0)
    |> Enum.reduce(acc, &parse_item_line(&1, &2, key))
  end

  defp parse_line({"plurals", attributes, items}, acc) do
    [key] = for {k, v} <- attributes, k == "name", do: v

    Enum.reduce(items, acc, &parse_plural_item_line(&1, &2, key))
  end

  # Comments are only appended in the comments key of the accumulator
  defp parse_line({:comment, comment}, acc) do
    Map.put(acc, :comment, Enum.concat(acc.comment, [comment]))
  end

  # Unsupported elements are simply ignored
  defp parse_line(_, acc), do: acc

  defp parse_plural_item_line({"item", attributes, [value]}, acc, key) do
    {_, name} = List.keyfind(attributes, "quantity", 0)

    acc
    |> Map.put(
      :entries,
      Enum.concat(acc.entries, [
        %Entry{
          key: "#{key}.#{name}",
          value: sanitize_value_to_string(value),
          index: acc.index,
          comment: serialize_comment(acc.comment),
          value_type: Langue.ValueType.parse(value),
          plural: true
        }
      ])
    )
    |> Map.put(:comment, [])
    |> Map.put(:index, acc.index + 1)
  end

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
          comment: serialize_comment(acc.comment),
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

  defp serialize_comment([]), do: nil
  defp serialize_comment(comment), do: Enum.join(comment, "\n")
end
