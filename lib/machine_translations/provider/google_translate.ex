defmodule Accent.MachineTranslations.Provider.GoogleTranslate do
  @moduledoc false
  defstruct config: nil

  defimpl Accent.MachineTranslations.Provider do
    alias Accent.MachineTranslations.TranslatedText
    alias Tesla.Middleware

    @supported_languages ~w(
    af
    sq
    am
    ar
    hy
    az
    eu
    be
    bn
    bs
    bg
    ca
    ceb
    zh-CN
    zh
    zh-TW
    co
    hr
    cs
    da
    nl
    en
    eo
    et
    fi
    fr
    fy
    gl
    ka
    de
    el
    gu
    ht
    ha
    haw
    he
    iw
    hi
    hmn
    hu
    is
    ig
    id
    ga
    it
    ja
    jv
    kn
    kk
    km
    rw
    ko
    ku
    ky
    lo
    lv
    lt
    lb
    mk
    mg
    ms
    ml
    mt
    mi
    mr
    mn
    my
    ne
    no
    ny
    or
    ps
    fa
    pl
    pt
    pa
    ro
    ru
    sm
    gd
    sr
    st
    sn
    sd
    si
    sk
    sl
    so
    es
    su
    sw
    sv
    tl
    tg
    ta
    tt
    te
    th
    tr
    tk
    uk
    ur
    ug
    uz
    vi
    cy
    xh
    yi
    yo
    zu
  )
    def id(_), do: :google_translate

    def enabled?(%{config: %{"key" => key}}) do
      not is_nil(key) and match?({:ok, %{"project_id" => _}}, Jason.decode(key))
    end

    def enabled?(_), do: false

    def translate(provider, contents, source, target) do
      contents_with_no_translate = Enum.map(contents, &mark_no_translate/1)

      with {:ok, {source, target}} <-
             Accent.MachineTranslations.map_source_and_target(
               source,
               target,
               @supported_languages
             ),
           params = %{
             contents: contents_with_no_translate,
             mimeType: "text/plain",
             sourceLanguageCode: source,
             targetLanguageCode: target
           },
           {:ok, %{body: %{"translations" => translations}}} <-
             Tesla.post(client(provider.config), ":translateText", params) do
        {:ok, Enum.map(translations, &%TranslatedText{text: unmark_no_translate(&1["translatedText"])})}
      else
        {:ok, %{status: status, body: body}} when status > 201 ->
          {:error, body}

        error ->
          error
      end
    end

    defp mark_no_translate(value) do
      Enum.find_value(Langue.placeholder_regex(), fn regex ->
        matches = Regex.scan(regex, value)

        if Enum.any?(matches) do
          Enum.reduce(List.flatten(matches), value, fn match, value ->
            String.replace(value, match, ~s(<span translate="no">#{match}</span>))
          end)
        end
      end) || value
    end

    defp unmark_no_translate(value) do
      String.replace(value, ~r/<span translate="no">([^<]+)<\/span>/i, "\\1")
    end

    defmodule Auth do
      @moduledoc false
      @behaviour Tesla.Middleware

      @impl Tesla.Middleware
      def call(env, next, opts) do
        case auth_enabled?() && Goth.Token.fetch(%{source: opts}) do
          {:ok, %{token: token, type: type}} ->
            env
            |> Tesla.put_header("authorization", type <> " " <> token)
            |> Tesla.run(next)

          _ ->
            Tesla.run(env, next)
        end
      end

      defp auth_enabled? do
        !Application.get_env(:goth, :disabled)
      end
    end

    defp client(config) do
      {base_url, auth_source} = parse_auth_config(config)

      middlewares =
        List.flatten([
          {Middleware.Timeout, [timeout: :infinity]},
          {Middleware.BaseUrl, base_url},
          {Auth, auth_source},
          Middleware.DecodeJson,
          Middleware.EncodeJson,
          Middleware.Logger,
          Middleware.Telemetry
        ])

      Tesla.client(middlewares)
    end

    defp parse_auth_config(config) do
      case Jason.decode!(Map.fetch!(config, "key")) do
        %{"project_id" => project_id, "type" => "service_account"} = credentials ->
          {
            "https://translation.googleapis.com/v3/projects/#{project_id}",
            {:service_account, credentials,
             [
               scopes: [
                 "https://www.googleapis.com/auth/cloud-translation",
                 "https://www.googleapis.com/auth/cloud-platform"
               ]
             ]}
          }
      end
    end
  end
end
