defmodule Langue.Formatter.Gettext.Serializer do
  @moduledoc false
  @behaviour Langue.Formatter.Serializer

  alias Expo.Message.Singular
  alias Langue.Utils.NestedParserHelper

  def serialize(%{entries: entries, document: document, language: language}) do
    comments =
      if document.top_of_the_file_comment do
        document.top_of_the_file_comment
        |> String.trim_leading()
        |> String.split("\n", trim: true)
        |> Enum.map(&String.replace_prefix(&1, "#", ""))
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
        |> Enum.map(&unescape_header/1)
        |> prepend_empty_header()
      else
        []
      end

    render =
      %Expo.Messages{
        messages: parse_entries(entries),
        top_comments: comments,
        headers: headers
      }
      |> Expo.PO.compose()
      |> IO.iodata_to_binary()

    %Langue.Formatter.SerializerResult{render: render}
  end

  defp prepend_empty_header([]), do: []

  defp prepend_empty_header(["" | _rest] = headers), do: headers

  defp prepend_empty_header(headers), do: ["" | headers]

  defp unescape_header(header), do: String.replace(header, "\\n", "\n")

  defp parse_entries(entries) do
    entries
    |> NestedParserHelper.group_by_key_with_index(0, "__KEY__")
    |> Enum.map(&do_parse_entries/1)
  end

  defp do_parse_entries({_key, [entry]}) do
    case Regex.named_captures(~r/(?<id>.*)\.__CONTEXT__(?<context>.*)/, entry.key) do
      %{"id" => id, "context" => context} ->
        %Singular{
          comments: parse_comments(entry.comment),
          msgid: split_string(id),
          msgstr: split_string(entry.value),
          msgctxt: split_string(context)
        }

      _ ->
        %Singular{
          comments: parse_comments(entry.comment),
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

    %Expo.Message.Plural{
      comments: parse_comments(plural_entry.comment),
      msgid: msgid,
      msgid_plural: split_string(plural_entry.value),
      msgstr:
        for {entry, index} <- Enum.with_index(entries, 0), into: %{} do
          {index, split_string(entry.value)}
        end
    }
  end

  defp parse_comments(comment) do
    comment
    |> split_string([])
    |> Enum.map(&String.replace_prefix(&1, "#", ""))
  end

  defp split_string(str, empty \\ [""])
  defp split_string("", empty), do: empty
  defp split_string(nil, empty), do: empty

  defp split_string(string, _empty) do
    ~r/[^\n]*\n/
    |> Regex.split(string, include_captures: true, trim: true)
    |> case do
      ["\n" | rest] -> ["" | rest]
      values -> values
    end
  end

  defp remove_key_suffix(string), do: String.replace(string, ".__KEY___", "")

  defp replace_language_header(string, language) do
    String.replace(string, ~r/Language: [^\n]*/, "Language: #{language.slug}")
  end

  defp replace_plural_forms_header(string, language) do
    String.replace(string, ~r/Plural-Forms: [^\n]*/, "Plural-Forms: #{language.plural_forms}")
  end
end
