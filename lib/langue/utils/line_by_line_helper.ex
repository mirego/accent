defmodule Langue.Utils.LineByLineHelper do
  alias Langue.Entry

  def parse_lines(render, parse_line, split \\ "\n") do
    render
    |> String.split(split)
    |> Enum.reduce(%{comment: [], entries: [], index: 1}, &parse_line.(&1, &2))
    |> Map.get(:entries)
  end

  def serialize_lines(entries, text_acc, prop_line) do
    Enum.reduce(entries, text_acc, &Kernel.<>(&2, serialize_line(&1, prop_line)))
  end

  defp serialize_line(entry = %Entry{comment: comment}, prop_line) when not is_nil(comment) and comment !== "" do
    comment <> "\n" <> prop_line.(entry)
  end

  defp serialize_line(entry = %Entry{}, prop_line) do
    prop_line.(entry)
  end

  def parse_line(line, prop_line_regex, acc) do
    case Regex.named_captures(prop_line_regex, line) do
      %{"key" => key, "value" => value, "comment" => comment} ->
        acc
        |> Map.put(:entries, Enum.concat(acc.entries, [%Entry{key: key, value: value, index: acc.index, comment: String.trim_trailing(comment, "\n")}]))
        |> Map.put(:index, acc.index + 1)

      %{"key" => key, "value" => value} ->
        acc
        |> Map.put(:entries, Enum.concat(acc.entries, [%Entry{key: key, value: value, index: acc.index, comment: Enum.join(acc.comment, "\n")}]))
        |> Map.put(:comment, [])
        |> Map.put(:index, acc.index + 1)

      nil ->
        Map.put(acc, :comment, Enum.concat(acc.comment, [line]))
    end
  end
end
