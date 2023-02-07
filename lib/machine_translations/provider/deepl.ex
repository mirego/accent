defmodule Accent.MachineTranslations.Provider.Deepl do
  defstruct config: nil

  defimpl Accent.MachineTranslations.Provider do
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

    alias Accent.MachineTranslations.TranslatedText
    alias Tesla.Middleware

    def enabled?(%{config: %{"key" => key}}), do: not is_nil(key)
    def enabled?(_), do: false

    def translate(provider, contents, source, target) do
      target = String.upcase(to_language_code(target))
      source = String.upcase(to_language_code(source))

      case Tesla.post(client(provider.config["key"]), "translate", %{text: contents, source_lang: source, target_lang: target}) do
        {:ok, %{body: %{"translations" => translations}}} ->
          {:ok, Enum.map(translations, &%TranslatedText{text: &1["text"]})}

        {:ok, %{status: status, body: body}} when status > 201 ->
          {:error, body}

        error ->
          error
      end
    end

    defmodule Auth do
      @behaviour Tesla.Middleware

      @impl Tesla.Middleware
      def call(env, next, opts) do
        env
        |> Tesla.put_header("authorization", "DeepL-Auth-Key #{opts[:key]}")
        |> Tesla.run(next)
      end
    end

    defp client(key) do
      middlewares =
        List.flatten([
          {Middleware.Timeout, [timeout: :infinity]},
          {Middleware.BaseUrl, "https://api-free.deepl.com/v2/"},
          {Auth, [key: key]},
          Middleware.DecodeJson,
          Middleware.EncodeJson,
          Middleware.Logger,
          Middleware.Telemetry
        ])

      Tesla.client(middlewares)
    end

    defp to_language_code(language) when language in @supported_languages do
      language
    end

    defp to_language_code(language) do
      case String.split(language, "-", parts: 2) do
        [prefix, _] when prefix in @supported_languages -> prefix
        _ -> :unsupported
      end
    end
  end
end
