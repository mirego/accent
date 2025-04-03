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
    Enum.map(entries, &entry_to_messages(&1, config))
  end

  def create_lint_entry(args) do
    Repo.insert(%ProjectLintEntry{
      project_id: args.project_id,
      check_ids: args.check_ids,
      type: args.type,
      value: args.value
    })
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
