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

        defp normalize_lang(nil), do: nil
    defp normalize_lang(slug) when is_binary(slug) do
      slug
      |> String.upcase()
      |> String.split("-", parts: 2)
      |> List.first()
    end

    # e.g. supported_glossary_langs="DE,EN,FR,IT,ES,PT"
    defp parse_langs_list(nil), do: MapSet.new()
    defp parse_langs_list(str) when is_binary(str) do
      str
      |> String.split(~r/[\s,]+/, trim: true)
      |> Enum.map(&String.upcase/1)
      |> MapSet.new()
    end

    def translate(provider, contents, source_arg, target_arg) do
      with {:ok, {source, target}} <-
            Accent.MachineTranslations.map_source_and_target(source_arg, target_arg, @supported_languages),
          # Normalize for DeepL
          source_lang <- source |> normalize_lang(),
          target_lang <- target |> normalize_lang(),
          params <-
            %{
              text: contents,
              source_lang: source_lang,
              target_lang: target_lang
            }
            |> maybe_put_glossary(provider.config, source_lang, target_lang),
          {:ok, %{body: %{"translations" => translations}}} <-
            Tesla.post(client(provider.config["key"]), "translate", params) do
        {:ok, Enum.map(translations, &%TranslatedText{text: &1["text"]})}
      else
        {:ok, %{status: status, body: body}} when status > 201 -> {:error, body}
        error -> error
      end
    end

    defp glossary_map_from_env(config) do
      raw = config["glossary_map"] || System.get_env("DEEPL_GLOSSARY_MAP")

      parse_glossary_map(raw)
    end

    # Parse the glossary map from the environment. Can be in format
    # JSON: {"<source_lang>-><target_lang>": "<glossary_id>"} => {"DE->EN": "abc", "DE->IT": "def"}
    # Or String: "[source_lang]->[target_lang]:[glossary_id],..." => "DE->EN:abc,DE->IT:def"
    defp parse_glossary_map(nil), do: %{}
    defp parse_glossary_map(raw) when is_binary(raw) do
      case Jason.decode(raw) do
        {:ok, %{} = map} ->
          map
          |> Enum.reduce(%{}, fn {pair, id}, acc ->
            case String.split(pair, "->", parts: 2) do
              [src, tgt] ->
                src_n = normalize_lang(src)
                tgt_n = normalize_lang(tgt)
                Map.put(acc, {src_n, tgt_n}, id)
              _ ->
                acc
            end
          end)

        _non_json ->
          raw
          |> String.split(~r/[\s,]+/, trim: true)
          |> Enum.reduce(%{}, fn entry, acc ->
            case String.split(entry, ":", parts: 2) do
              [pair, id] ->
                case String.split(pair, "->", parts: 2) do
                  [src, tgt] ->
                    src_n = normalize_lang(src)
                    tgt_n = normalize_lang(tgt)
                    Map.put(acc, {src_n, tgt_n}, id)
                  _ -> acc
                end
              _ -> acc
            end
          end)
      end
    end

    defp maybe_put_glossary(params, config, source_lang, target_lang) do
      cond do
        is_nil(source_lang) or is_nil(target_lang) -> params
        source_lang == target_lang -> params
        true ->
          id =
            glossary_map_from_env(config)
            |> Map.get({source_lang, target_lang})

          if is_binary(id) and id != "" do
            Map.put(params, :glossary_id, id)
          else
            params
          end
      end
    end

    defp maybe_put_glossary(params, _), do: params

    def translate(provider, contents, source_arg, target_arg) do
      with {:ok, {source, target}} <-
             Accent.MachineTranslations.map_source_and_target(source_arg, target_arg, @supported_languages),
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
      @behaviour Middleware

      @impl Middleware
      def call(env, next, opts) do
        env
        |> Tesla.put_header("authorization", "DeepL-Auth-Key #{opts[:key]}")
        |> Tesla.run(next)
      end
    end

    defp client(key) do
      base_url =
        if String.ends_with?(key, ":fx") do
          "https://api-free.deepl.com/v2/"
        else
          "https://api.deepl.com/v2/"
        end

      middlewares =
        List.flatten([
          {Middleware.Timeout, [timeout: :infinity]},
          {Middleware.BaseUrl, base_url},
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
