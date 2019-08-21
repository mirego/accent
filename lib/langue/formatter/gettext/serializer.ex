defmodule Langue.Formatter.Gettext.Serializer do
  @behaviour Langue.Formatter.Serializer

  alias Langue.Utils.NestedParserHelper

  def serialize(%{entries: entries, document: document, language: language}) do
    comments =
      if document.top_of_the_file_comment do
        document.top_of_the_file_comment
        |> String.trim_leading()
        |> String.split("\n", trim: true)
      else
        []
      end

    headers =
      if document.header do
        document.header
        |> String.trim_leading()
        |> String.replace("\"", "")
        |> replace_language_header(language)
        |> replace_plural_forms_header(language)
        |> String.replace(~r/\n(\w)/, "_\\1")
        |> String.split("_", trim: true)
      else
        ""
      end

    render =
      %Gettext.PO{
        translations: parse_entries(entries),
        top_of_the_file_comments: comments,
        headers: headers
      }
      |> Gettext.PO.dump()
      |> IO.iodata_to_binary()

    %Langue.Formatter.SerializerResult{render: render}
  end

  defp parse_entries(entries) do
    entries
    |> NestedParserHelper.group_by_key_with_index(0, "__KEY__")
    |> Enum.map(&do_parse_entries/1)
  end

  defp do_parse_entries({_key, [entry]}) do
    case Regex.named_captures(~r/(?<id>.*)\.__CONTEXT__(?<context>.*)/, entry.key) do
      %{"id" => id, "context" => context} ->
        %Gettext.PO.Translation{
          comments: split_string(entry.comment, []),
          msgid: split_string(id),
          msgstr: split_string(entry.value),
          msgctxt: split_string(context)
        }

      _ ->
        %Gettext.PO.Translation{
          comments: split_string(entry.comment, []),
          msgid: split_string(entry.key),
          msgstr: split_string(entry.value)
        }
    end
  end

  defp do_parse_entries({_key, [plural_entry | entries]}) do
    msgid =
      plural_entry.key
      |> remove_key_suffix()
      |> split_string()

    %Gettext.PO.PluralTranslation{
      comments: split_string(plural_entry.comment, []),
      msgid: msgid,
      msgid_plural: split_string(plural_entry.value),
      msgstr:
        for {entry, index} <- Enum.with_index(entries, 0), into: %{} do
          {index, split_string(entry.value)}
        end
    }
  end

  defp split_string(str, empty \\ [""])
  defp split_string("", empty), do: empty
  defp split_string(nil, empty), do: empty

  defp split_string(string, _empty) do
    Regex.split(~r/[^\n]*\n/, string, include_captures: true, trim: true)
  end

  defp remove_key_suffix(string), do: String.replace(string, ".__KEY___", "")

  defp replace_language_header(string, language) do
    String.replace(string, ~r/Language: [^\n]*/, "Language: #{language.slug}")
  end

  defp replace_plural_forms_header(string, language) do
    String.replace(string, ~r/Plural-Forms: [^\n]*/, "Plural-Forms: #{language.plural_forms}")
  end
end
