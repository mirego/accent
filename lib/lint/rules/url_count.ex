defmodule Accent.Lint.Rules.URLCount do
  @behaviour Accent.Lint.Rule

  alias Accent.Lint.Message

  @url_regex ~r/(https?:\/\/)?([0-9a-z]+\.)?[-_0-9a-z]+\.[0-9a-z]+/i

  def lint(value = %{entry: %{is_master: true}}, _), do: value

  def lint(value, _) do
    text = value.entry.value
    master = value.entry.master_value

    text_urls = Regex.scan(@url_regex, text)
    text_urls_lenght = length(text_urls)
    master_urls = Regex.scan(@url_regex, master)
    master_urls_lenght = length(master_urls)

    if text_urls_lenght !== master_urls_lenght do
      Accent.Lint.add_message(
        value,
        %Message{
          text: text,
          replacements: [],
          rule: %Message.Rule{
            id: "URL_COUNT",
            description: ~s[Value contains a different number of URL (#{text_urls_lenght}) from the master value (#{master_urls_lenght})]
          }
        }
      )
    else
      value
    end
  end
end
