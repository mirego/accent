defmodule Accent.Lint.Checks.DoubleSpace do
  alias Accent.Lint.Message
  alias Accent.Lint.Replacement

  def applicable(_), do: true

  def check(entry) do
    fixed_text = String.replace(entry.value, "  ", " ")

    if fixed_text !== entry.value do
      [
        %Message{
          check: :double_spaces,
          text: entry.value,
          replacement: %Replacement{value: fixed_text, label: fixed_text}
        }
      ]
    else
      []
    end
  end
end
