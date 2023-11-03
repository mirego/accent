defmodule Accent.Lint.Checks.DoubleSpace do
  @moduledoc false
  @behaviour Accent.Lint.Check

  alias Accent.Lint.Message
  alias Accent.Lint.Replacement

  @impl true
  def enabled?, do: not Accent.Lint.Checks.Spelling.enabled?()

  @impl true
  def applicable(entry), do: is_binary(entry.value)

  @impl true
  def check(entry) do
    fixed_text = String.replace(entry.value, "  ", " ")

    if fixed_text !== entry.value do
      %Message{
        check: :double_spaces,
        text: entry.value,
        replacement: %Replacement{value: fixed_text, label: fixed_text}
      }
    end
  end
end
