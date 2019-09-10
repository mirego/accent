defmodule Accent.TranslationsRenderer do
  alias Langue

  def render(args) do
    {:ok, serializer} = Langue.serializer_from_format(args[:document].format)
    entries = entries(args)

    serialzier_input = %Langue.Formatter.ParserResult{
      entries: entries,
      language: %Langue.Language{
        slug: args[:language].slug,
        plural_forms: args[:language].plural_forms
      },
      document: %Langue.Document{
        path: args[:document].path,
        master_language: Accent.Revision.language(args[:master_revision]).slug,
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

  def entries(args) do
    translations = args[:translations]
    master_translations = Enum.group_by(args[:master_translations], & &1.key)
    value_map = Map.get(args, :value_map, & &1.corrected_text)

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

  defp fetch_master_value([master_translation | _], value_map) do
    value_map.(master_translation)
  end
end
