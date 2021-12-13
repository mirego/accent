defmodule Accent.Lint.Checks.PlaceholderCount do
  alias Accent.Lint.Message

  def applicable(_), do: true

  def check(entry) do
    master_matches = match_placeholders(entry.master_value)
    value_matches = match_placeholders(entry.value)

    if master_matches !== value_matches do
      [
        %Message{
          check: :placeholder_count,
          text: entry.value,
        }
      ]
    else
      []
    end
  end

  defp match_placeholders(text) do
    Langue.format_modules()
    |> Enum.map(& &1.placeholder_regex())
    |> Enum.reject(& &1 === :not_supported)
    |> Enum.map(&Regex.scan(&1, text))
  end
end
