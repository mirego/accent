defmodule Accent.MachineTranslations.Provider.Deepl do
  @moduledoc false
  defstruct config: nil

  defimpl Accent.MachineTranslations.Provider do
    alias Accent.MachineTranslations.TranslatedText

    @supported_languages ~w(
      bg
      cs
      da
      de
      el
      en
      es
      et
      fi
      fr
      hu
      id
      it
      ja
      ko
      lt
      lv
      nb
      nl
      pl
      pt
      ro
      ru
      sk
      sl
      sv
      tr
      uk
      zh
    )

    def id(_), do: :deepl

    def enabled?(%{config: %{"key" => key}}), do: not is_nil(key)
    def enabled?(_), do: false

    def translate(provider, contents, source_arg, target_arg) do
      with {:ok, {source, target}} <-
             Accent.MachineTranslations.map_source_and_target(source_arg, target_arg, @supported_languages),
           params = %{text: contents, source_lang: source && String.upcase(source), target_lang: String.upcase(target)},
           {:ok, %{status: status, body: %{"translations" => translations}}} when status in 200..299 <-
             Req.post(client(provider.config["key"]), url: "translate", json: params) do
        {:ok, Enum.map(translations, &%TranslatedText{text: &1["text"]})}
      else
        {:ok, %{status: status, body: body}} when status > 201 ->
          {:error, body}

        error ->
          error
      end
    end

    defp client(key) do
      base_url =
        if String.ends_with?(key, ":fx") do
          "https://api-free.deepl.com/v2/"
        else
          "https://api.deepl.com/v2/"
        end

      Accent.HTTPClient.new(base_url: base_url, auth: "DeepL-Auth-Key #{key}", receive_timeout: :infinity)
    end
  end
end
