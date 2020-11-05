defmodule Accent.MachineTranslations do
  alias Accent.MachineTranslations.TranslatedText

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
    values = Enum.map(entries, & &1.value)

    with {module, config} <- provider_from_service(:translate_list),
         {:ok, translated_values} <- module.translate_list(values, source_language.slug, target_language.slug, config) do
      entries
      |> Enum.with_index()
      |> Enum.map(fn {entry, index} ->
        case Enum.at(translated_values, index) do
          %TranslatedText{text: text} -> %{entry | value: text}
          _ -> entry
        end
      end)
    else
      _ -> entries
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
