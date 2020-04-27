defmodule Accent.Lint.Rules.TrailingColon do
  @moduledoc """
  Checks that colons are replicated between both source and translation.
  """

  @behaviour Accent.Lint.Rule

  @regex ~r/.+:$/

  alias Accent.Lint.Message

  def lint(value = %{entry: %{is_master: true}}, _), do: value

  def lint(value, _) do
    text = String.trim_trailing(value.entry.value)
    master = String.trim_trailing(value.entry.master_value)
    master_has_trailing_colon? = Regex.match?(@regex, master)
    text_has_trailing_colon? = Regex.match?(@regex, text)

    if master_has_trailing_colon? and !text_has_trailing_colon? do
      Accent.Lint.add_message(
        value,
        %Message{
          context: %Message.Context{
            offset: 0,
            length: String.length(text),
            text: text
          },
          text: Accent.Lint.display_trailing_text(value.entry.master_value),
          replacements: [%Message.Replacement{value: "#{text}:"}],
          rule: %Message.Rule{
            id: "TRAILING_COLON",
            description: "Translation does not match trailing colons of the source"
          }
        }
      )
    else
      value
    end
  end
end
