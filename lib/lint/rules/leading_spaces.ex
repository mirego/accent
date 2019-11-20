defmodule Accent.Lint.Rules.LeadingSpaces do
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
            id: "LEADING_SPACES",
            description: "Value contains leading space"
          }
        }
      )
    else
      value
    end
  end

  defp fix_value(value) do
    String.trim_leading(value)
  end
end
