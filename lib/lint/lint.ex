defmodule Accent.Lint do
  @moduledoc false
  @checks [
    Accent.Lint.Checks.DoubleSpace,
    Accent.Lint.Checks.FirstLetterCase,
    Accent.Lint.Checks.LeadingSpaces,
    Accent.Lint.Checks.PlaceholderCount,
    Accent.Lint.Checks.ThreeDotsEllipsis,
    Accent.Lint.Checks.TrailingSpaces,
    Accent.Lint.Checks.ApostropheAsSingleQuote,
    Accent.Lint.Checks.URLCount
  ]

  @typep entry :: Langue.Entry.t()

  defmodule Message do
    @moduledoc false
    @enforce_keys ~w(check text)a
    defstruct check: nil, text: nil, replacement: nil
  end

  defmodule Replacement do
    @moduledoc false
    @enforce_keys ~w(value label)a
    defstruct value: nil, label: nil
  end

  @spec lint(list(entry)) :: list(map())
  def lint(entries) do
    Enum.map(entries, &entry_to_messages/1)
  end

  defp entry_to_messages(entry) do
    {entry,
     Enum.flat_map(@checks, fn check ->
       if check.applicable(entry), do: List.wrap(check.check(entry)), else: []
     end)}
  end
end
