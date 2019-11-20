defmodule Accent.Lint.Rules.DoubleSpaces do
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
            id: "DOUBLE_SPACES",
            description: "Value contains double spaces"
          }
        }
      )
    else
      value
    end
  end

  defp fix_value(value) do
    String.replace(value, ~r/  +/, " ")
  end
end
