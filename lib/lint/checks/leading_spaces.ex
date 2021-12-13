defmodule Accent.Lint.Checks.LeadingSpaces do
  alias Accent.Lint.Message
  alias Accent.Lint.Replacement

  def applicable(_), do: true

  def check(entry) do
    fixed_text = String.trim_leading(entry.value)

    if fixed_text !== entry.value do
      [
        %Message{
          check: :leading_spaces,
          text: entry.value,
          replacement: %Replacement{value: fixed_text, label: fixed_text}
        }
      ]
    else
      []
    end
  end
end
