defmodule Accent.Lint.Rules.TrailingSpaces do
  @behaviour Accent.Lint.Rule

  alias Accent.Lint.Message

  defstruct description: nil

  def lint(value, _) do
    text = value.entry.value
    fixed_text = fix_value(text)

    if text !== fixed_text do
      Accent.Lint.add_message(
        value,
        %Message{
          text: text,
          context: %Message.Context{
            offset: 0,
            length: String.length(text),
            text: text
          },
          replacements: [%Message.Replacement{value: fixed_text}],
          rule: %Message.Rule{
            id: "TRAILING_SPACES",
            description: "Value contains trailing space"
          }
        }
      )
    else
      value
    end
  end

  defp fix_value(value) do
    String.trim_trailing(value)
  end
end
