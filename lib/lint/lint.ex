defmodule Accent.Lint do
  @moduledoc false

  defmodule Config do
    @moduledoc false
    defstruct enabled_rule_ids: []

    @type t :: %__MODULE__{}
  end

  defmodule Message do
    @moduledoc false
    @enforce_keys ~w(check text)a
    defstruct check: nil, text: nil, replacement: nil, message: nil, offset: nil, length: nil

    @type t :: %__MODULE__{}
  end

  defmodule Replacement do
    @moduledoc false
    @enforce_keys ~w(value label)a
    defstruct value: nil, label: nil
  end

  @type message :: Message.t()
  @type entry :: Langue.Entry.t()

  @checks Map.filter(
            %{
              "first_letter_case" => Accent.Lint.Checks.FirstLetterCase,
              "leading_spaces" => Accent.Lint.Checks.LeadingSpaces,
              "placeholder_count" => Accent.Lint.Checks.PlaceholderCount,
              "three_dots_ellipsis" => Accent.Lint.Checks.ThreeDotsEllipsis,
              "trailing_spaces" => Accent.Lint.Checks.TrailingSpaces,
              "apostrophe_as_single_quote" => Accent.Lint.Checks.ApostropheAsSingleQuote,
              "double_space" => Accent.Lint.Checks.DoubleSpace,
              "spelling" => Accent.Lint.Checks.Spelling,
              "url_count" => Accent.Lint.Checks.URLCount
            },
            fn {_, check} -> check.enabled?() end
          )

  @spec lint(list(entry), Config.t()) :: list(map())
  def lint(entries, config \\ %Config{}) do
    Enum.map(entries, &entry_to_messages(&1, config))
  end

  defp entry_to_messages(entry, config) do
    checks =
      if Enum.any?(config.enabled_rule_ids) do
        Map.filter(@checks, fn {rule_id, _check_module} -> rule_id in config.enabled_rule_ids end)
      else
        @checks
      end

    check_modules = Map.values(checks)

    {entry,
     Enum.flat_map(check_modules, fn check ->
       if check.applicable(entry), do: List.wrap(check.check(entry)), else: []
     end)}
  end
end
