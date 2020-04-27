defmodule Accent.Lint.Rules.TrailingEllipsis do
  @moduledoc """
  Checks that ellipsis are replicated between both source and translation.
  """

  @behaviour Accent.Lint.Rule

  @regex ~r/.+…$/

  alias Accent.Lint.Message

  def lint(value = %{entry: %{is_master: true}}, _), do: value

  def lint(value, _) do
    text = value.entry.value
    master = value.entry.master_value
    master_has_trailing_ellipsis? = Regex.match?(@regex, master)
    text_has_trailing_ellipsis? = Regex.match?(@regex, text)

    if master_has_trailing_ellipsis? and !text_has_trailing_ellipsis? do
      Accent.Lint.add_message(
        value,
        %Message{
          context: %Message.Context{
            offset: 0,
            length: String.length(text),
            text: text
          },
          text: Accent.Lint.display_trailing_text(value.entry.master_value),
          replacements: [%Message.Replacement{value: "#{text}…"}],
          rule: %Message.Rule{
            id: "TRAILING_ELLIPSIS",
            description: "Translation does not match ellipsis of the source"
          }
        }
      )
    else
      value
    end
  end
end
