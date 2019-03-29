defmodule Accent.TranslationsRenderer do
  alias Langue

  def render(args) do
    value_map = Map.get(args, :value_map, & &1.corrected_text)
    serializer = fetch_serializer(args[:document].format)
    master_translations = Enum.group_by(args[:master_translations], & &1.key)
    entries = fetch_entries(args[:translations], master_translations, value_map)

    serialzier_input = %Langue.Formatter.ParserResult{
      entries: entries,
      language: %Langue.Language{
        slug: args[:language].slug,
        plural_forms: args[:language].plural_forms
      },
      document: %Langue.Document{
        path: args[:document].path,
        master_language: args[:master_revision].language.slug,
        top_of_the_file_comment: args[:document].top_of_the_file_comment,
        header: args[:document].header
      }
    }

    try do
      serializer.(serialzier_input)
    rescue
      _ -> Langue.Formatter.SerializerResult.empty()
    end
  end

  defp fetch_serializer(format) do
    case Langue.serializer_from_format(format) do
      {:ok, serializer} -> serializer
    end
  end

  defp fetch_entries(translations, master_translations, value_map) do
    Enum.map(translations, fn translation ->
      master_translation = Map.get(master_translations, translation.key)

      %Langue.Entry{
        master_value: fetch_master_value(master_translation, value_map),
        key: translation.key,
        value: value_map.(translation),
        comment: translation.file_comment,
        index: translation.file_index,
        value_type: translation.value_type
      }
    end)
  end

  defp fetch_master_value(nil, _), do: nil
  defp fetch_master_value([], _), do: nil

  defp fetch_master_value([master_translation], value_map) do
    value_map.(master_translation)
  end
end
