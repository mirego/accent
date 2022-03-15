defmodule Accent.MachineTranslations.Adapter.GoogleTranslations do
  @behaviour Accent.MachineTranslations.Adapter

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

  @impl Accent.MachineTranslations.Adapter
  def translate_text(content, source, target, config) do
    case translate_list([content], source, target, config) do
      {:ok, [translation]} -> {:ok, translation}
      error -> error
    end
  end

  @impl Accent.MachineTranslations.Adapter
  def translate_list(contents, source, target, config) do
    target = to_language_code(target)
    source = to_language_code(source)

    case Tesla.post(client(config), ":translateText", %{contents: contents, mimeType: "text/plain", sourceLanguageCode: source, targetLanguageCode: target}) do
      {:ok, %{body: %{"translations" => translations}}} ->
        {:ok, Enum.map(translations, &%TranslatedText{text: &1["translatedText"]})}

      error ->
        error
    end
  end

  defmodule Auth do
    @behaviour Tesla.Middleware

    @impl Tesla.Middleware
    def call(env, next, opts) do
      case auth_enabled?() && Goth.Token.for_scope(opts[:scope]) do
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
    project_id = project_id_from_config(config)

    middlewares =
      List.flatten([
        {Middleware.Timeout, [timeout: :infinity]},
        {Middleware.BaseUrl, "https://translation.googleapis.com/v3/projects/#{project_id}"},
        {Auth, [scope: "https://www.googleapis.com/auth/cloud-translation"]},
        Middleware.DecodeJson,
        Middleware.EncodeJson,
        Middleware.Logger,
        Middleware.Telemetry
      ])

    Tesla.client(middlewares)
  end

  defp project_id_from_config(config) do
    key = Keyword.fetch!(config, :key)
    Jason.decode!(key)["project_id"]
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
