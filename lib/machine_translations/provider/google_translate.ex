defmodule Accent.MachineTranslations.Provider.GoogleTranslate do
  @moduledoc false
  defstruct config: nil

  defimpl Accent.MachineTranslations.Provider do
    alias Accent.MachineTranslations.TranslatedText

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
      not is_nil(key) and match?({:ok, %{"project_id" => _}}, JSON.decode(key))
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
           {:ok, %{status: status, body: %{"translations" => translations}}} when status in 200..299 <-
             Req.post(client(provider.config), url: ":translateText", json: params) do
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

    defp client(config) do
      {base_url, auth_source} = parse_auth_config(config)

      Accent.HTTPClient.new(base_url: base_url, auth: authorization(auth_source), receive_timeout: :infinity)
    end

    defp authorization(auth_source) do
      case !Application.get_env(:goth, :disabled) && Goth.Token.fetch(%{source: auth_source}) do
        {:ok, %{token: token, type: type}} -> type <> " " <> token
        _ -> nil
      end
    end

    defp parse_auth_config(config) do
      (%{"project_id" => project_id, "type" => "service_account"} = credentials) =
        JSON.decode!(Map.fetch!(config, "key"))

      {"https://translation.googleapis.com/v3/projects/#{project_id}",
       {:service_account, credentials,
        [
          scopes: [
            "https://www.googleapis.com/auth/cloud-translation",
            "https://www.googleapis.com/auth/cloud-platform"
          ]
        ]}}
    end
  end
end
