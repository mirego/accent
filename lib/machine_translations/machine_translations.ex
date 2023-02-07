defmodule Accent.MachineTranslations do
  alias Accent.MachineTranslations.Provider
  alias Accent.MachineTranslations.TranslatedText

  @translation_chunk_size 100
  @untranslatable_string_length_limit 2000
  @untranslatable_placeholder "__^__"

  def enabled?(config) do
    provider = provider_from_config(config)
    Provider.enabled?(provider)
  end

  @spec translate([map()], String.t(), String.t(), struct()) :: [map()]
  def translate(entries, source_language, target_language, config) do
    provider = provider_from_config(config)

    entries
    |> Enum.map(&filter_long_value/1)
    |> Enum.chunk_every(@translation_chunk_size)
    |> Enum.flat_map(fn values ->
      case Provider.translate(provider, values, source_language.slug, target_language.slug) do
        {:ok, translated_values} ->
          entries
          |> Enum.zip(translated_values)
          |> Enum.map(fn {entry, translated_text} ->
            case translated_text do
              %TranslatedText{text: @untranslatable_placeholder} -> entry
              %TranslatedText{text: text} -> %{entry | value: text}
              _ -> entry
            end
          end)

        _ ->
          entries
      end
    end)
  end

  defp provider_from_config(nil), do: %Provider.NotImplemented{}

  defp provider_from_config(machine_translations_config) do
    struct_module =
      case machine_translations_config["provider"] do
        "google_translate" -> Provider.GoogleTranslate
        "deepl" -> Provider.Deepl
        _ -> Provider.NotImplemented
      end

    struct!(struct_module, config: fetch_config(machine_translations_config))
  end

  defp fetch_config(%{"provider" => provider, "use_platform" => true}) do
    Map.get(Application.get_env(:accent, __MODULE__)[:default_providers_config], provider)
  end

  defp fetch_config(%{"config" => config}), do: config

  defp filter_long_value(%{value: value}) when value in ["", nil], do: @untranslatable_placeholder

  defp filter_long_value(entry) do
    if String.length(entry.value) > @untranslatable_string_length_limit do
      @untranslatable_placeholder
    else
      entry.value
    end
  end
end
