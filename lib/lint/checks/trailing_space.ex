defmodule Accent.Lint.Checks.TrailingSpaces do
  @moduledoc false
  alias Accent.Lint.Message
  alias Accent.Lint.Replacement

  def applicable(_), do: true

  def check(entry) do
    fixed_text = String.trim_trailing(entry.value)

    if fixed_text !== entry.value do
      %Message{
        check: :trailing_space,
        text: entry.value,
        replacement: %Replacement{value: fixed_text, label: fixed_text}
      }
    end
  end
end
