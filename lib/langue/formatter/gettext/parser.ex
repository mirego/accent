defmodule Langue.Formatter.Gettext.Parser do
  @moduledoc false
  @behaviour Langue.Formatter.Parser

  alias Langue.Entry
  alias Langue.Utils.Placeholders
  alias Langue.ValueType

  def parse(%{render: render, document: document}) do
    {:ok, po} = Gettext.PO.parse_string(render)
    entries = parse_translations(po)
    top_of_the_file_comment = join_string(po.top_of_the_file_comments, "\n")
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

  defp parse_translations(%{translations: translations}) do
    translations
    |> Enum.flat_map(&parse_translation/1)
    |> Enum.with_index(1)
    |> Enum.map(fn {entry, index} -> %{entry | index: index} end)
    |> Placeholders.parse(Langue.Formatter.Gettext.placeholder_regex())
  end

  defp parse_translation(%{msgid_plural: _} = translation) do
    plural_entry = %Entry{
      comment: join_string(translation.comments),
      key: join_string(translation.msgid) <> key_suffix("_"),
      value: join_string(translation.msgid_plural),
      plural: true,
      value_type: "plural",
      locked: true
    }

    Enum.reduce(translation.msgstr, [plural_entry], fn {plural_index, value}, acc ->
      Enum.concat(acc, [
        %Entry{
          key: join_string(translation.msgid) <> key_suffix(plural_index),
          value: join_string(value),
          plural: true,
          value_type: ValueType.parse(join_string(value))
        }
      ])
    end)
  end

  defp parse_translation(%{msgctxt: nil} = translation) do
    [
      %Entry{
        comment: join_string(translation.comments),
        key: join_string(translation.msgid),
        value: join_string(translation.msgstr),
        value_type: ValueType.parse(join_string(translation.msgstr))
      }
    ]
  end

  defp parse_translation(translation) do
    [
      %Entry{
        comment: join_string(translation.comments),
        key: join_string(translation.msgid) <> context_suffix(translation.msgctxt),
        value: join_string(translation.msgstr),
        value_type: ValueType.parse(join_string(translation.msgstr))
      }
    ]
  end

  defp join_string(list, joiner \\ "")
  defp join_string([], _joiner), do: nil
  defp join_string(list, joiner), do: Enum.join(list, joiner)

  defp key_suffix(id), do: ".__KEY__#{id}"

  defp context_suffix(""), do: ""

  defp context_suffix(id), do: ".__CONTEXT__#{id}"
end
