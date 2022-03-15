defmodule Accent.MachineTranslations do
  alias Accent.MachineTranslations.TranslatedText

  @translation_chunk_size 500
  @untranslatable_string_length_limit 2000
  @untranslatable_placeholder "_"

  def translate_list_enabled? do
    not is_nil(provider_from_service(:translate_list))
  end

  def translate_text_enabled? do
    not Enum.empty?(provider_from_service(:translate_text))
  end

  def translate_text(text, source_language, target_language) do
    :translate_text
    |> provider_from_service()
    |> Enum.map(fn {module, config} ->
      case module.translate_text(text, source_language.slug, target_language.slug, config) do
        {:ok, %TranslatedText{} = translated} -> %{translated | id: to_id(text)}
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  def translate_entries(entries, source_language, target_language) do
    entries
    |> Enum.chunk_every(@translation_chunk_size)
    |> Enum.flat_map(fn entries ->
      values = Enum.map(entries, &filter_long_value/1)

      with {module, config} <- provider_from_service(:translate_list),
           {:ok, translated_values} <- module.translate_list(values, source_language.slug, target_language.slug, config) do
        entries
        |> Enum.zip(translated_values)
        |> Enum.map(fn {entry, translated_text} ->
          case translated_text do
            %TranslatedText{text: @untranslatable_placeholder} -> entry
            %TranslatedText{text: text} -> %{entry | value: text}
            _ -> entry
          end
        end)
      else
        _ -> entries
      end
    end)
  end

  defp filter_long_value(%{value: value}) when value in ["", nil], do: @untranslatable_placeholder

  defp filter_long_value(entry) do
    if String.length(entry.value) > @untranslatable_string_length_limit do
      @untranslatable_placeholder
    else
      entry.value
    end
  end

  defp to_id(text) do
    :md5
    |> :crypto.hash(text)
    |> :base64.encode_to_string()
    |> to_string()
  end

  defp provider_from_service(service) do
    Application.get_env(:accent, __MODULE__)[service]
  end
end
