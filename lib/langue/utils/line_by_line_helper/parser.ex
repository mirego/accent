defmodule Langue.Utils.LineByLineHelper.Parser do
  @moduledoc false
  alias Langue.Entry
  alias Langue.ValueType

  defmodule LineState do
    @moduledoc false
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

  defp build_entry(%{captures: %{"key" => key, "value" => value, "comment" => comment}} = acc) do
    comment = if(comment !== "", do: String.trim_trailing(comment, "\n"))
    entry = %Entry{key: key, value: value, index: acc.index, comment: comment, value_type: ValueType.parse(value)}

    %{acc | entry: entry}
  end

  defp build_entry(%{comments: comments, captures: %{"key" => key, "value" => value}} = acc) do
    comment = if(comments !== [], do: Enum.join(comments, "\n"))
    entry = %Entry{key: key, value: value, index: acc.index, comment: comment, value_type: ValueType.parse(value)}

    %{acc | entry: entry, comments: []}
  end

  defp build_entry(%{comments: comments, line: line} = acc) do
    %{acc | comments: Enum.concat(comments, [line])}
  end

  defp add_entries(%{entry: nil} = acc), do: acc

  defp add_entries(%{entries: entries, entry: entry, index: index} = acc) do
    %{acc | entries: Enum.concat(entries, [entry]), entry: nil, index: index + 1}
  end
end
