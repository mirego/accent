defmodule Accent.Lint.Rules.TrailingExclamation do
  @moduledoc """
  Checks that exclamations are replicated between both source and translation.
  """

  @behaviour Accent.Lint.Rule

  @regex ~r/.+!$/

  alias Accent.Lint.Message

  def lint(value = %{entry: %{is_master: true}}, _), do: value

  def lint(value, _) do
    text = value.entry.value
    master = value.entry.master_value
    master_has_trailing_exclamation? = Regex.match?(@regex, master)
    text_has_trailing_exclamation? = Regex.match?(@regex, text)

    if master_has_trailing_exclamation? and !text_has_trailing_exclamation? do
      Accent.Lint.add_message(
        value,
        %Message{
          context: %Message.Context{
            offset: 0,
            length: String.length(text),
            text: text
          },
          text: Accent.Lint.display_trailing_text(value.entry.master_value),
          replacements: [%Message.Replacement{value: text <> "!"}],
          rule: %Message.Rule{
            id: "TRAILING_EXCLAMATION",
            description: "Translation does not match exclamation of the source"
          }
        }
      )
    else
      value
    end
  end
end
