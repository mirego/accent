defmodule Accent.Lint.Checks.ApostropheAsSingleQuote do
  @moduledoc false
  @behaviour Accent.Lint.Check

  alias Accent.Lint.Message
  alias Accent.Lint.Replacement

  @applicable_languages ~w(fr fr-CA fr-QC)

  @impl true
  def enabled?, do: true

  @impl true
  def applicable(entry, _) do
    entry.language_slug in @applicable_languages and not String.match?(entry.value, ~r/MMMM?|YYYY?|HH|AA/i)
  end

  @impl true
  def check(entry, _) do
    fixed_text = Regex.replace(~r/(\w)(')/, entry.value, "\\1’")

    if fixed_text !== entry.value do
      %Message{
        check: :apostrophe_as_single_quote,
        text: entry.value,
        replacement: %Replacement{value: fixed_text, label: fixed_text}
      }
    end
  end
end
