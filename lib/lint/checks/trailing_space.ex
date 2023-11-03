defmodule Accent.Lint.Checks.TrailingSpaces do
  @moduledoc false
  @behaviour Accent.Lint.Check

  alias Accent.Lint.Message
  alias Accent.Lint.Replacement

  @impl true
  def enabled?, do: true

  @impl true
  def applicable(entry), do: entry.value not in ["", " ", nil]

  @impl true
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
