defmodule Accent.Lint.Checks.URLCount do
  alias Accent.Lint.Message

  def applicable(_), do: true

  def check(entry) do
    master_url_count = urls_count(entry.master_value)
    value_url_count = urls_count(entry.value)

    if master_url_count !== value_url_count do
      %Message{
        check: :url_count,
        text: entry.value
      }
    end
  end

  defp urls_count(text) do
    Regex.scan(~r/(https?|ftps?|mailto):\/\/[a-z0-9]+\./, text)
  end
end
