defmodule LanguageTool do
  @moduledoc false

  def check(lang, text, opts \\ []) do
    if lang in list_languages() do
      cache_key = cache_key([lang, text])

      case Cachex.get!(:language_tool_cache, cache_key) do
        nil ->
          metadata = %{language_code: lang, cache_key: cache_key, text_length: String.length(text)}

          :telemetry.span(
            [:accent, :language_tool, :check],
            metadata,
            fn ->
              placeholder_regex = Keyword.get(opts, :placeholder_regex)
              annotated_text = LanguageTool.AnnotatedText.build(text, placeholder_regex)

              result =
                GenServer.call(LanguageTool.Server, {:check, lang, Jason.encode!(%{items: annotated_text})}, :infinity)

              Cachex.set!(:language_tool_cache, cache_key, result)

              {result, metadata}
            end
          )

        result ->
          result
      end
    else
      empty_matches(lang, text, :unsupported_language)
    end
  catch
    _ -> empty_matches(lang, text, :check_internal_error)
  end

  defp cache_key(contents) do
    :erlang.md5(contents)
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
