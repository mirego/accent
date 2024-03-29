defmodule Accent.MachineTranslations.Provider.Deepl do
  @moduledoc false
  defstruct config: nil

  defimpl Accent.MachineTranslations.Provider do
    alias Accent.MachineTranslations.TranslatedText
    alias Tesla.Middleware

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

    def translate(provider, contents, source, target) do
      with {:ok, {source, target}} <-
             Accent.MachineTranslations.map_source_and_target(source, target, @supported_languages),
           params = %{text: contents, source_lang: source && String.upcase(source), target_lang: String.upcase(target)},
           {:ok, %{body: %{"translations" => translations}}} <-
             Tesla.post(client(provider.config["key"]), "translate", params) do
        {:ok, Enum.map(translations, &%TranslatedText{text: &1["text"]})}
      else
        {:ok, %{status: status, body: body}} when status > 201 ->
          {:error, body}

        error ->
          error
      end
    end

    defmodule Auth do
      @moduledoc false
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
  end
end
