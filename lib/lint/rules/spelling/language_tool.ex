defmodule Accent.Lint.Rules.Spelling.LanguageTool do
  @behaviour Accent.Lint.Rules.Spelling.Gateway

  alias Accent.Lint.Message

  @headers [{"Content-Type", "application/x-www-form-urlencoded"}]
  @supported_languages ~w(
    ast-ES
    be-BY
    br-FR
    ca-ES
    zh-CN
    da-DK
    nl
    en
    en-AU
    en-CA
    en-GB
    en-NZ
    en-ZA
    en-US
    eo
    fr
    gl-ES
    de
    de-AT
    de-DE
    de-CH
    el-GR
    it
    ja-JP
    km-KH
    fa
    pl-PL
    pt
    pt-AO
    pt-BR
    pt-MZ
    pt-PT
    ro-RO
    ru-RU
    sk-SK
    sl-SI
    es
    sv
    tl-PH
    ta-IN
    uk-UA
  )

  def check(value, language) do
    body = "text=#{URI.encode(value)}&language=#{convert_language(language)}"

    with {:ok, response} <- HTTPoison.post(base_url(), body, @headers),
         {:ok, %{"matches" => matches}} <- Jason.decode(response.body) do
      Enum.map(matches, &map_match/1)
    else
      _ -> []
    end
  end

  defp convert_language("de"), do: "de-DE"
  defp convert_language("pt"), do: "pt-PT"
  defp convert_language("en"), do: "en-US"
  defp convert_language(language) when language in @supported_languages, do: language
  defp convert_language(_), do: "auto"

  defp map_match(match) do
    context = %Message.Context{
      offset: match["context"]["offset"],
      length: match["context"]["length"],
      text: match["context"]["text"]
    }

    replacements =
      Enum.map(
        match["replacements"],
        &%Message.Replacement{
          value: &1["value"]
        }
      )

    %Message{
      text: text_from_context(context),
      padded_text: padded_text_from_context(context),
      fixed_text: Enum.find_value(replacements, & &1.value),
      context: context,
      rule: %Message.Rule{id: match["rule"]["id"], description: match["rule"]["description"]},
      replacements: replacements
    }
  end

  defp text_from_context(context) do
    String.slice(context.text, context.offset, context.length)
  end

  defp padded_text_from_context(context = %{offset: 0}), do: padded_text_from_context(%{context | offset: 1})

  defp padded_text_from_context(context) do
    String.slice(context.text, context.offset - 1, context.length + 1)
  end

  defp base_url do
    Application.get_env(:accent, Accent.Lint)[:spelling_gateway_url] <> "/v2/check"
  end
end
