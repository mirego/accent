defmodule LanguageTool.Backend do
  @moduledoc false

  require Logger

  def start(config) do
    path = Application.app_dir(:accent, "priv/native")

    args = [
      executable(),
      "-cp",
      Path.join(path, "language-tool.jar"),
      "com.mirego.accent.languagetool.AppKt",
      "--languages",
      Enum.join(config.languages, ",")
    ]

    args =
      if Enum.any?(config.disabled_rule_ids) do
        args ++ ["--disabledRuleIds", Enum.join(config.disabled_rule_ids, ",")]
      else
        args
      end

    {:ok, backend} = Exile.Process.start_link(args)
    receive_ready?(backend)
    backend
  end

  def available? do
    !!executable()
  end

  defp executable do
    System.find_executable("java")
  end

  def check(process, lang, text) do
    result =
      text
      |> String.split("\n")
      |> Enum.map(&process_check(process, lang, &1))
      |> Enum.reject(&is_nil/1)
      |> Enum.reduce(
        %{"offset" => 0, "language" => nil, "error" => nil, "text" => [], "matches" => [], "markups" => []},
        fn result, acc ->
          matches =
            Enum.map(result["matches"], fn match ->
              Map.update!(match, "offset", &(&1 + acc["offset"]))
            end)

          acc
          |> Map.update!("markups", &(&1 ++ result["markups"]))
          |> Map.update!("matches", &(&1 ++ matches))
          |> Map.put("language", result["language"])
          |> Map.put("error", result["error"])
          |> Map.update!("offset", &(&1 + String.length(result["text"]) + 1))
          |> Map.update!("text", &(&1 ++ [result["text"]]))
        end
      )

    result
    |> Map.delete("offset")
    |> Map.update!("text", &Enum.join(&1, "\n"))
  end

  defp receive_ready?(backend) do
    case Exile.Process.read(backend) do
      {:ok, ">\n"} ->
        Logger.info("LanguageTool is ready to spellcheck")
        true

      _ ->
        receive_ready?(backend)
    end
  end

  defp process_check(process, lang, text) do
    lang = sanitize_lang(lang)
    Exile.Process.write(process, IO.iodata_to_binary([String.pad_trailing(lang, 7), text, "\n"]))

    with {:ok, data} <- Exile.Process.read(process),
         {:ok, data} <- Jason.decode(data) do
      data
    else
      _ -> nil
    end
  end

  defp sanitize_lang(lang) do
    if lang === "en" do
      "en-US"
    else
      lang
    end
  end
end
