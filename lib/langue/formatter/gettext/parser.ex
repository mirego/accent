defmodule Langue.Formatter.Gettext.Parser do
  @moduledoc false
  @behaviour Langue.Formatter.Parser

  alias Langue.Entry
  alias Langue.Utils.Placeholders
  alias Langue.ValueType

  def parse(%{render: render, document: document}) do
    {:ok, po} = Expo.PO.parse_string(render)
    entries = parse_messages(po)
    top_of_the_file_comment = join_comments(po.top_comments, "\n")
    header = join_string(po.headers, "\n")

    %Langue.Formatter.ParserResult{
      entries: entries,
      document: %{
        document
        | top_of_the_file_comment: top_of_the_file_comment,
          header: header
      }
    }
  end

  defp parse_messages(%{messages: messages}) do
    messages
    |> Enum.reject(& &1.obsolete)
    |> Enum.flat_map(&parse_message/1)
    |> Enum.with_index(1)
    |> Enum.map(fn {entry, index} -> %{entry | index: index} end)
    |> Placeholders.parse(Langue.Formatter.Gettext.placeholder_regex())
  end

  defp parse_message(%{msgid_plural: _} = message) do
    plural_entry = %Entry{
      comment: join_comments(message.comments),
      key: join_string(message.msgid) <> key_suffix("_"),
      value: join_string(message.msgid_plural),
      plural: true,
      value_type: "plural",
      locked: true
    }

    plural_entries =
      Enum.map(message.msgstr, fn {plural_index, value} ->
        %Entry{
          key: join_string(message.msgid) <> key_suffix(plural_index),
          value: join_string(value),
          plural: true,
          value_type: ValueType.parse(join_string(value))
        }
      end)

    [plural_entry | plural_entries]
  end

  defp parse_message(message) do
    value = join_string(message.msgstr)

    [
      %Entry{
        comment: join_comments(message.comments),
        key: join_string(message.msgid) <> context_suffix(message.msgctxt),
        value: value,
        value_type: ValueType.parse(value)
      }
    ]
  end

  defp join_comments(comments, joiner \\ "") do
    comments
    |> Enum.map(&("#" <> &1))
    |> join_string(joiner)
  end

  defp join_string(list, joiner \\ "")
  defp join_string([], _joiner), do: nil
  defp join_string(list, joiner), do: Enum.join(list, joiner)

  defp key_suffix(id), do: ".__KEY__#{id}"

  defp context_suffix(nil), do: ""

  defp context_suffix(msgctxt), do: ".__CONTEXT__#{join_string(msgctxt)}"
end
