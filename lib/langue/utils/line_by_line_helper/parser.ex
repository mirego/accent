defmodule Langue.Utils.LineByLineHelper.Parser do
  alias Langue.{Entry, ValueType}

  defmodule LineState do
    defstruct comments: [], entries: [], index: 1, entry: nil, captures: nil
  end

  def lines(render, prop_line_regex, split \\ "\n") do
    render
    |> String.split(split)
    |> Enum.reduce(%LineState{}, &parse_line(&1, prop_line_regex, &2))
    |> Map.get(:entries)
  end

  defp parse_line(line, prop_line_regex, acc) do
    acc
    |> Map.put(:line, line)
    |> Map.put(:captures, Regex.named_captures(prop_line_regex, line))
    |> build_entry()
    |> add_entries()
  end

  defp build_entry(acc = %{captures: %{"key" => key, "value" => value, "comment" => comment}}) do
    comment = if(comment !== "", do: String.trim_trailing(comment, "\n"), else: nil)
    entry = %Entry{key: key, value: value, index: acc.index, comment: comment, value_type: ValueType.parse(value)}

    %{acc | entry: entry}
  end

  defp build_entry(acc = %{comments: comments, captures: %{"key" => key, "value" => value}}) do
    comment = if(comments !== [], do: Enum.join(comments, "\n"), else: nil)
    entry = %Entry{key: key, value: value, index: acc.index, comment: comment, value_type: ValueType.parse(value)}

    %{acc | entry: entry, comments: []}
  end

  defp build_entry(acc = %{comments: comments, line: line}) do
    %{acc | comments: Enum.concat(comments, [line])}
  end

  defp add_entries(acc = %{entry: nil}), do: acc

  defp add_entries(acc = %{entries: entries, entry: entry, index: index}) do
    %{acc | entries: Enum.concat(entries, [entry]), entry: nil, index: index + 1}
  end
end
