defmodule LanguageTool do
  @moduledoc false

  def check(lang, text, opts \\ []) do
    if MapSet.member?(list_languages(), lang) do
      cache_key = cache_key([lang, text])

      case Cachex.fetch(:language_tool_cache, cache_key, fn _key ->
             metadata = %{language_code: lang, cache_key: cache_key, text_length: String.length(text)}

             result =
               :telemetry.span(
                 [:accent, :language_tool, :check],
                 metadata,
                 fn ->
                   placeholder_regex = Keyword.get(opts, :placeholder_regex)
                   annotated_text = LanguageTool.AnnotatedText.build(text, placeholder_regex)
                   payload = JSON.encode_to_iodata!(%{items: annotated_text})

                   result =
                     GenServer.call(
                       LanguageTool.Server,
                       {:check, lang, IO.iodata_to_binary(payload)},
                       :infinity
                     )

                   {result, metadata}
                 end
               )

             {:commit, result}
           end) do
        {action, result} when action in [:ok, :commit] -> result
        _ -> empty_matches(lang, text, :check_internal_error)
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
