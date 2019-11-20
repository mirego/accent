defmodule Accent.Lint.Rules.PlaceholderCount do
  @behaviour Accent.Lint.Rule

  alias Accent.Lint.Message

  @placeholder_regex ~r/(\[\w+\])|(\{\w+\})|(\(\w+\))/

  def lint(value = %{entry: %{is_master: true}}, _), do: value

  def lint(value, _) do
    text = value.entry.value
    master = value.entry.master_value

    text_placeholders = Regex.scan(@placeholder_regex, text)
    text_placeholders_lenght = length(text_placeholders)
    master_placeholders = Regex.scan(@placeholder_regex, master)
    master_placeholders_lenght = length(master_placeholders)

    if text_placeholders_lenght !== master_placeholders_lenght do
      Accent.Lint.add_message(
        value,
        %Message{
          text: text,
          replacements: [],
          rule: %Message.Rule{
            id: "PLACEHOLDER_COUNT",
            description: ~s[Value contains a different number of placeholders (#{text_placeholders_lenght}) from the master value (#{master_placeholders_lenght})]
          }
        }
      )
    else
      value
    end
  end
end
