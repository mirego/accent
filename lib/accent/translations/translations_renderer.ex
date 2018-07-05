defmodule Accent.TranslationsRenderer do
  alias Langue

  def render(args) do
    serializer = fetch_serializer(args[:document_format])
    entries = fetch_entries(args[:translations])

    parser_result = %Langue.Formatter.ParserResult{
      entries: entries,
      language: args[:language],
      top_of_the_file_comment: args[:document_top_of_the_file_comment],
      header: args[:document_header]
    }

    try do
      serializer.(parser_result)
    catch
      _ -> Langue.Formatter.SerializerResult.empty()
    end
  end

  defp fetch_serializer(format) do
    case Langue.serializer_from_format(format) do
      {:ok, serializer} -> serializer
    end
  end

  defp fetch_entries(translations) do
    Enum.map(translations, fn translation ->
      %Langue.Entry{
        key: translation.key,
        value: translation.corrected_text,
        comment: translation.file_comment,
        index: translation.file_index,
        value_type: translation.value_type
      }
    end)
  end
end
