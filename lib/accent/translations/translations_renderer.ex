defmodule Accent.TranslationsRenderer do
  @moduledoc false
  def render_entries(args) do
    {:ok, serializer} = Langue.serializer_from_format(args.document.format)

    serialzier_input = %Langue.Formatter.ParserResult{
      entries: args.entries,
      language: %Langue.Language{
        slug: args.language.slug,
        plural_forms: args.language.plural_forms
      },
      document: %Langue.Document{
        path: args.document.path,
        master_language: args.master_language.slug,
        top_of_the_file_comment: args.document.top_of_the_file_comment,
        header: args.document.header
      }
    }

    try do
      serializer.(serialzier_input)
    rescue
      _ -> Langue.Formatter.SerializerResult.empty()
    end
  end

  def render_translations(args) do
    value_map = Map.get(args, :value_map, & &1.corrected_text)
    entries = translations_to_entries(args[:translations], args[:master_translations], value_map)

    render_entries(%{
      entries: entries,
      document: args[:document],
      language: args[:language],
      master_language: args[:master_language]
    })
  end

  defp translations_to_entries(translations, master_translations, value_map) do
    master_translations = Enum.group_by(List.wrap(master_translations), & &1.key)

    Enum.map(translations, fn translation ->
      master_translation = Map.get(master_translations, translation.key)

      %Langue.Entry{
        master_value: fetch_master_value(master_translation, value_map),
        key: translation.key,
        value: value_map.(translation),
        comment: translation.file_comment,
        index: translation.file_index,
        value_type: translation.value_type,
        plural: translation.plural,
        placeholders: translation.placeholders,
        locked: translation.locked
      }
    end)
  end

  defp fetch_master_value(nil, _), do: nil
  defp fetch_master_value([], _), do: nil

  defp fetch_master_value([master_translation | _], value_map) do
    value_map.(master_translation)
  end
end
