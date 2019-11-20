defmodule Accent.Lint.Rules.TrailingStop do
  @moduledoc """
  Checks that full stops are replicated between both source and translation.
  """

  @behaviour Accent.Lint.Rule

  @regex ~r/.+\.$/

  alias Accent.Lint.Message

  def lint(value = %{entry: %{is_master: true}}, _), do: value

  def lint(value, _) do
    text = value.entry.value
    master = value.entry.master_value
    master_has_trailing_stop? = Regex.match?(@regex, master)
    text_has_trailing_stop? = Regex.match?(@regex, text)

    if master_has_trailing_stop? and !text_has_trailing_stop? do
      Accent.Lint.add_message(
        value,
        %Message{
          text: Accent.Lint.display_trailing_text(value.entry.master_value),
          replacements: [%Message.Replacement{value: "#{text}."}],
          rule: %Message.Rule{
            id: "TRAILING_STOP",
            description: "Translation does not match full stop of the source"
          }
        }
      )
    else
      value
    end
  end
end
