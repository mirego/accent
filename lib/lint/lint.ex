defmodule Accent.Lint do
  @moduledoc false
  alias Accent.ProjectLintEntry
  alias Accent.Repo

  defmodule Config do
    @moduledoc false
    defstruct enabled_check_ids: [], lint_entries: []

    @type t :: %__MODULE__{}
  end

  defmodule Message do
    @moduledoc false
    @enforce_keys ~w(check text)a
    defstruct check: nil, details: %{}, text: nil, replacement: nil, message: nil, offset: nil, length: nil

    @type t :: %__MODULE__{}
  end

  defmodule Replacement do
    @moduledoc false
    @enforce_keys ~w(value label)a
    defstruct value: nil, label: nil
  end

  @type message :: Message.t()
  @type entry :: Langue.Entry.t()

  @fix_max_iterations 10

  @checks [
    {"first_letter_case", Accent.Lint.Checks.FirstLetterCase},
    {"leading_spaces", Accent.Lint.Checks.LeadingSpaces},
    {"placeholder_count", Accent.Lint.Checks.PlaceholderCount},
    {"three_dots_ellipsis", Accent.Lint.Checks.ThreeDotsEllipsis},
    {"trailing_space", Accent.Lint.Checks.TrailingSpaces},
    {"apostrophe_as_single_quote", Accent.Lint.Checks.ApostropheAsSingleQuote},
    {"double_space", Accent.Lint.Checks.DoubleSpace},
    {"spelling", Accent.Lint.Checks.Spelling},
    {"url_count", Accent.Lint.Checks.URLCount}
  ]

  @spec lint(list(entry), Config.t()) :: list({entry, list(map())})
  def lint(entries, config \\ %Config{}) do
    telemetry_metadata = %{entries_count: length(entries)}

    :telemetry.span([:accent, :lint], telemetry_metadata, fn ->
      results = Enum.map(entries, &entry_to_messages(&1, config))
      issues_count = results |> Enum.flat_map(&elem(&1, 1)) |> length()

      {results, Map.put(telemetry_metadata, :issues_count, issues_count)}
    end)
  end

  @spec filter_messages_by_check(list(message), String.t() | nil) :: list(message)
  def filter_messages_by_check(messages, nil), do: messages
  def filter_messages_by_check(messages, check), do: Enum.filter(messages, &(&1.check === check))

  @spec fix_updates(list({entry, list(message)}), %{optional(any()) => any()}, Config.t(), String.t() | nil) ::
          list({any(), String.t()})
  def fix_updates(results, translations_by_id, config, check_filter) do
    results
    |> Enum.map(fn {entry, messages} ->
      {entry, Map.get(translations_by_id, entry.id), filter_messages_by_check(messages, check_filter)}
    end)
    |> Enum.filter(fn {_entry, translation, messages} -> translation && Enum.any?(messages) end)
    |> Enum.map(fn {entry, translation, messages} ->
      {translation, fix_text(entry, messages, config, check_filter)}
    end)
    |> Enum.filter(fn {translation, text} -> text !== translation.corrected_text end)
  end

  @spec fix_text(entry, list(message), Config.t(), String.t() | nil) :: String.t()
  def fix_text(entry, messages, config, check_filter) do
    do_fix_text(entry, messages, config, check_filter, @fix_max_iterations)
  end

  defp do_fix_text(entry, _messages, _config, _check_filter, 0), do: entry.value

  defp do_fix_text(entry, messages, config, check_filter, iterations) do
    case Enum.find(messages, &(&1.replacement && &1.replacement.value)) do
      nil ->
        entry.value

      message ->
        entry = %{entry | value: message.replacement.value}
        [{_entry, next_messages}] = lint([entry], config)
        next_messages = filter_messages_by_check(next_messages, check_filter)
        do_fix_text(entry, next_messages, config, check_filter, iterations - 1)
    end
  end

  @spec check_stats(list({entry, list(message)})) :: list(%{check: any(), count: non_neg_integer()})
  def check_stats(results) do
    results
    |> Enum.flat_map(fn {_entry, messages} -> messages end)
    |> Enum.frequencies_by(& &1.check)
    |> Enum.map(fn {check, count} -> %{check: check, count: count} end)
  end

  def create_lint_entry(args) do
    %ProjectLintEntry{}
    |> ProjectLintEntry.create_changeset(args)
    |> Repo.insert()
  end

  def update_lint_entry(lint_entry, args) do
    lint_entry
    |> ProjectLintEntry.update_changeset(args)
    |> Repo.update()
  end

  def delete_lint_entry(lint_entry) do
    Repo.delete(lint_entry)
  end

  defp entry_to_messages(entry, config) do
    checks = get_cached_checks()

    checks =
      if Enum.any?(config.enabled_check_ids) do
        Enum.filter(checks, fn {check_id, _check_module} -> check_id in config.enabled_check_ids end)
      else
        checks
      end

    checks =
      Enum.reject(checks, fn {check, _} ->
        Enum.any?(config.lint_entries, fn lint_entry ->
          check in lint_entry.check_ids and
            (lint_entry.type === :all or
               (lint_entry.type === :key and entry.key === lint_entry.value))
        end)
      end)

    messages =
      Enum.flat_map(checks, fn {_check, check_module} ->
        if check_module.applicable(entry, config) do
          List.wrap(check_module.check(entry, config))
        else
          []
        end
      end)

    {entry, messages}
  end

  defp get_cached_checks do
    case :persistent_term.get({__MODULE__, :lint_checks}, :not_found) do
      :not_found ->
        checks = Enum.filter(@checks, fn {_, check} -> check.enabled?() end)
        :persistent_term.put({__MODULE__, :lint_checks}, checks)
        checks

      cached_checks ->
        cached_checks
    end
  end
end
