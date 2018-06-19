defmodule Langue.Formatter.Gettext.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Entry

  def parse(%{render: render}) do
    {:ok, po} = Gettext.PO.parse_string(render)
    entries = parse_translations(po)
    top_of_the_file_comment = join_string(po.top_of_the_file_comments)
    header = join_string(po.headers)

    %Langue.Formatter.ParserResult{
      entries: entries,
      top_of_the_file_comment: top_of_the_file_comment,
      header: header
    }
  end

  defp parse_translations(%{translations: translations}) do
    translations
    |> Enum.flat_map(&parse_translation/1)
    |> Enum.with_index(1)
    |> Enum.map(fn {entry, index} -> %{entry | index: index} end)
  end

  defp parse_translation(translation = %{msgid_plural: _}) do
    plural_entry = %Entry{
      comment: join_string(translation.comments),
      key: join_string(translation.msgid) <> key_suffix("_"),
      value: join_string(translation.msgid_plural),
      plural: true,
      locked: true
    }

    translation.msgstr
    |> Enum.reduce([plural_entry], fn {plural_index, value}, acc ->
      Enum.concat(acc, [
        %Entry{
          key: join_string(translation.msgid) <> key_suffix(plural_index),
          value: join_string(value),
          plural: true,
          value_type: Langue.ValueType.parse(join_string(value))
        }
      ])
    end)
  end

  defp parse_translation(translation) do
    [
      %Entry{
        comment: join_string(translation.comments),
        key: join_string(translation.msgid),
        value: join_string(translation.msgstr)
      }
    ]
  end

  defp join_string([]), do: ""
  defp join_string(list), do: Enum.join(list, "\n")

  defp key_suffix(id), do: ".__KEY__#{id}"
end
