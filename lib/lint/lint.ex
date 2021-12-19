defmodule Accent.Lint do
  @checks [
    Accent.Lint.Checks.DoubleSpace,
    Accent.Lint.Checks.FirstLetterCase,
    Accent.Lint.Checks.LeadingSpaces,
    Accent.Lint.Checks.PlaceholderCount,
    Accent.Lint.Checks.ThreeDotsEllipsis,
    Accent.Lint.Checks.TrailingSpaces,
    Accent.Lint.Checks.URLCount
  ]

  @typep entry :: Langue.Entry.t()

  defmodule Message do
    @enforce_keys ~w(check text)a
    defstruct check: nil, text: nil, replacement: nil
  end

  defmodule Replacement do
    @enforce_keys ~w(value label)a
    defstruct value: nil, label: nil
  end

  @spec lint(list(entry)) :: list(map())
  def lint(entries) do
    Enum.map(entries, fn entry ->
      messages =
        Enum.flat_map(@checks, fn check ->
          if check.applicable(entry) do
            check.check(entry)
          else
            []
          end
        end)

      {entry.id, messages}
    end)
  end
end
