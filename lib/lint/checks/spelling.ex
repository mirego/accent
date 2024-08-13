defmodule Accent.Lint.Checks.Spelling do
  @moduledoc false
  @behaviour Accent.Lint.Check

  alias Accent.Lint.Message
  alias Accent.Lint.Replacement

  @impl true
  def enabled?, do: LanguageTool.available?()

  @impl true
  def applicable(entry, _) do
    LanguageTool.ready?() and
      is_binary(entry.value) and
      not String.match?(entry.value, ~r/MMMM?|YYYY?|HH|AA/i) and
      ((!entry.is_master and entry.value !== entry.master_value) or entry.is_master) and
      String.length(entry.value) < 100 and String.length(entry.value) > 3
  end

  @impl true
  def check(entry, config) do
    matches =
      case LanguageTool.check(entry.language_slug, entry.value, placeholder_regex: entry.placeholder_regex) do
        %{"matches" => matches} -> matches
        _ -> []
      end

    matches
    |> Enum.reject(&reject_match?(&1, entry, config))
    |> Enum.map(fn match ->
      replacement = find_replacement(match, entry)

      %Message{
        check: :spelling,
        text: entry.value,
        offset: match["offset"],
        length: match["length"],
        message: match["message"],
        details: %{
          spelling_rule_id: match["rule"]["id"],
          spelling_rule_description: match["rule"]["description"]
        },
        replacement: replacement
      }
    end)
  end

  # credo:disable-for-next-line
  defp reject_match?(match, entry, config) do
    error_term = String.slice(entry.value, match["offset"], match["length"])

    match_project_lint_entries = fn ->
      Enum.any?(config.lint_entries, fn lint_entry ->
        cond do
          "spelling" in lint_entry.check_ids and lint_entry.ignore and lint_entry.type === :term and
              String.downcase(error_term) === String.downcase(lint_entry.value) ->
            true

          "spelling" in lint_entry.check_ids and lint_entry.ignore and
            lint_entry.type === :language_tool_rule_id and
              match["rule"]["id"] === lint_entry.value ->
            true

          true ->
            false
        end
      end)
    end

    error_term_starts_with_comma = fn -> String.match?(error_term, ~r/^,/) end
    match_starts_with_brace = fn -> match["offset"] === 0 and String.starts_with?(entry.value, "{") end
    error_term_is_icu_match = fn -> error_term === "other" and String.at(entry.value, match["offset"] - 2) === "}" end

    Enum.any?(
      [
        match_project_lint_entries,
        error_term_starts_with_comma,
        match_starts_with_brace,
        error_term_is_icu_match
      ],
      & &1.()
    )
  end

  defp find_replacement(match, entry) do
    case match["replacements"] do
      [%{"value" => fixed_value} | _] ->
        error_term = String.slice(entry.value, match["offset"], match["length"])

        value =
          String.replace(
            entry.value,
            error_term,
            fixed_value
          )

        %Replacement{value: value, label: fixed_value}

      _ ->
        nil
    end
  end
end
