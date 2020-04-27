defmodule Accent.Lint.Rules.TrailingQuestionMark do
  @moduledoc """
  Checks that question marks are replicated between both source and translation.
  """

  @behaviour Accent.Lint.Rule

  @regex ~r/.+\?$/

  alias Accent.Lint.Message

  def lint(value = %{entry: %{is_master: true}}, _), do: value

  def lint(value, _) do
    text = value.entry.value
    master = value.entry.master_value
    master_has_trailing_question_mark? = Regex.match?(@regex, master)
    text_has_trailing_question_mark? = Regex.match?(@regex, text)

    if master_has_trailing_question_mark? and !text_has_trailing_question_mark? do
      Accent.Lint.add_message(
        value,
        %Message{
          context: %Message.Context{
            offset: 0,
            length: String.length(text),
            text: text
          },
          text: Accent.Lint.display_trailing_text(value.entry.master_value),
          replacements: [%Message.Replacement{value: text <> "?"}],
          rule: %Message.Rule{
            id: "TRAILING_QUESTION_MARK",
            description: "Translation does not match question mark of the source"
          }
        }
      )
    else
      value
    end
  end
end
