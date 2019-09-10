defmodule Accent.Lint.Rules.Spelling do
  @behaviour Accent.Lint.Rule

  alias Accent.Lint

  @date_patterns ~w(YY MM ddhh HH hA SS ss NN nn)
  @password_patterns ~w(•)
  @placeholders ~w({ } [ ] %{)
  @pluralization_patterns ~w(=0 =1)

  @common_code_patterns @date_patterns ++ @password_patterns ++ @placeholders ++ @pluralization_patterns

  def lint(value, opts) do
    text = value.entry.value
    language = Keyword.get(opts, :language)

    text
    |> find_matches(language)
    |> Enum.filter(&valid?/1)
    |> Enum.reduce(value, &Lint.add_message(&2, &1))
  end

  defp find_matches(value, language) do
    spelling_gateway().check(value, language)
  end

  defp valid?(%{rule: %{id: "UPPERCASE_SENTENCE_START"}}), do: false
  defp valid?(%{context: %{length: length}}) when length <= 3, do: false

  for pattern <- @common_code_patterns do
    defp valid?(%{text: unquote(pattern) <> _}), do: false
    defp valid?(%{padded_text: unquote(pattern) <> _}), do: false
  end

  defp valid?(_match), do: true

  defp spelling_gateway do
    Application.get_env(:accent, Accent.Lint)[:spelling_gateway]
  end
end
