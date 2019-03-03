defmodule Accent.TranslationsRenderer do
  alias Langue

  def render(args) do
    value_map = Map.get(args, :value_map, & &1.corrected_text)
    serializer = fetch_serializer(args[:document_format])
    entries = fetch_entries(args[:translations], value_map)

    parser_result = %Langue.Formatter.ParserResult{
      entries: entries,
      language: args[:language],
      top_of_the_file_comment: args[:document_top_of_the_file_comment],
      header: args[:document_header]
    }

    try do
      serializer.(parser_result)
    rescue
      _ -> Langue.Formatter.SerializerResult.empty()
    end
  end

  defp fetch_serializer(format) do
    case Langue.serializer_from_format(format) do
      {:ok, serializer} -> serializer
    end
  end

  defp fetch_entries(translations, value_map) do
    Enum.map(translations, fn translation ->
      %Langue.Entry{
        key: translation.key,
        value: value_map.(translation),
        comment: translation.file_comment,
        index: translation.file_index,
        value_type: translation.value_type
      }
    end)
  end
end
