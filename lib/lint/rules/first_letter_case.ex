defmodule Accent.Lint.Rules.FirstLetterCase do
  @moduledoc """
  Checks that the first letter’s case of the source match the case of the first letter of the translation.
  """

  @behaviour Accent.Lint.Rule

  @regex ~r/^[A-Z]/

  alias Accent.Lint.Message

  def lint(value = %{entry: %{is_master: true}}, _), do: value

  def lint(value, _) do
    text = value.entry.value
    master = value.entry.master_value
    master_match? = Regex.match?(@regex, master)
    text_match? = Regex.match?(@regex, text)

    if (master_match? and !text_match?) || (!master_match? and text_match?) do
      Accent.Lint.add_message(
        value,
        %Message{
          text: Accent.Lint.display_leading_text(value.entry.master_value),
          rule: %Message.Rule{
            id: "FIRST_LETTER_CASE",
            description: "First letter of the translation does not match the case of the source"
          }
        }
      )
    else
      value
    end
  end
end
