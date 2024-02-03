defmodule Accent.MachineTranslations do
  @moduledoc false
  alias Accent.MachineTranslations.Provider
  alias Accent.MachineTranslations.TranslatedText

  @translation_chunk_size 100
  @untranslatable_string_length_limit 2000
  @untranslatable_placeholder "__^__"

  def id_from_config(config) do
    provider = provider_from_config(config)
    Provider.id(provider)
  end

  def enabled_on_action?(config, action) do
    config = config || %{}
    to_string(action) in Map.get(config, "enabled_actions", [])
  end

  def enabled?(config) do
    provider = provider_from_config(config)
    Provider.enabled?(provider)
  end

  @spec translate([map()], String.t(), String.t(), struct()) :: [map()] | {:error, any()}
  def translate(entries, source_language_slug, target_language_slug, config) do
    provider = provider_from_config(config)

    entries
    |> Enum.map(&filter_long_value/1)
    |> Enum.chunk_every(@translation_chunk_size)
    |> Enum.reduce_while([], fn chunked_entries, acc ->
      values = Enum.map(chunked_entries, & &1.value)

      case Provider.translate(provider, values, source_language_slug, target_language_slug) do
        {:ok, translated_values} ->
          translated_entries =
            chunked_entries
            |> Enum.zip(translated_values)
            |> Enum.map(fn {entry, translated_text} ->
              case translated_text do
                %TranslatedText{text: @untranslatable_placeholder} -> entry
                %TranslatedText{text: text} -> %{entry | value: text}
                _ -> entry
              end
            end)

          {:cont, acc ++ translated_entries}

        error ->
          {:halt, error}
      end
    end)
  end

  @spec map_source_and_target(String.t() | nil, String.t(), list(String.t())) ::
          {:ok, {String.t(), String.t()}} | {:error, atom()}
  def map_source_and_target(source, target, supported_languages) do
    source = source && String.downcase(source)
    target = String.downcase(target)

    source =
      if source in supported_languages, do: source, else: fallback_split_lanugage_slug(source, supported_languages)

    target =
      if target in supported_languages, do: target, else: fallback_split_lanugage_slug(target, supported_languages)

    cond do
      source === :unsupported and target === :unsupported -> {:error, :unsupported_source_and_target}
      source === :unsupported -> {:error, :unsupported_source}
      target === :unsupported -> {:error, :unsupported_target}
      true -> {:ok, {source, target}}
    end
  end

  defp fallback_split_lanugage_slug(nil, _supported_languages), do: nil

  defp fallback_split_lanugage_slug(language, supported_languages) do
    prefix =
      case String.split(language, "-", parts: 2) do
        [prefix, _] -> prefix
        _ -> nil
      end

    if prefix in supported_languages, do: prefix, else: :unsupported
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

  defp filter_long_value(%{value: value} = entry) when value in ["", nil],
    do: %{entry | value: @untranslatable_placeholder}

  defp filter_long_value(entry) do
    if String.length(entry.value) > @untranslatable_string_length_limit do
      %{entry | value: @untranslatable_placeholder}
    else
      entry
    end
  end
end
