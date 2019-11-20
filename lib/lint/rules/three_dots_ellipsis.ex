defmodule Accent.Lint.Rules.ThreeDotsEllipsis do
  @behaviour Accent.Lint.Rule

  alias Accent.Lint.Message

  def lint(value, _) do
    text = value.entry.value
    fixed_text = fix_value(text)

    if text !== fixed_text do
      Accent.Lint.add_message(
        value,
        %Message{
          text: text,
          replacements: [%Message.Replacement{value: fixed_text}],
          rule: %Message.Rule{
            id: "THREE_DOTS_ELLIPSIS",
            description: "Value contains three dots instead of ellipsis"
          }
        }
      )
    else
      value
    end
  end

  defp fix_value(value) do
    String.replace(value, "...", "…")
  end
end
