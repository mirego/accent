defmodule LanguageTool do
  @moduledoc false

  def check(lang, text, opts \\ []) do
    if lang in list_languages() do
      metadata = %{language_code: lang, text_length: String.length(text)}

      :telemetry.span(
        [:accent, :language_tool, :check],
        metadata,
        fn ->
          placeholder_regex = Keyword.get(opts, :placeholder_regex)
          annotated_text = LanguageTool.AnnotatedText.build(text, placeholder_regex)

          result =
            GenServer.call(LanguageTool.Server, {:check, lang, Jason.encode!(%{items: annotated_text})}, :infinity)

          {result, metadata}
        end
      )
    else
      empty_matches(lang, text, :unsupported_language)
    end
  catch
    _ -> empty_matches(lang, text, :check_internal_error)
  end

  defp empty_matches(lang, text, error) do
    %{"error" => error, "language" => lang, "matches" => [], "text" => text, "markups" => []}
  end

  def available? do
    LanguageTool.Server.available?()
  end

  def list_languages do
    LanguageTool.Server.list_languages()
  end

  def ready? do
    LanguageTool.Server.ready?()
  end
end
