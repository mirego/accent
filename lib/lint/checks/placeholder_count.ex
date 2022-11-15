defmodule Accent.Lint.Checks.PlaceholderCount do
  alias Accent.Lint.Message

  @regex Langue.placeholder_regex()

  def applicable(_), do: true

  def check(entry) do
    master_matches = master_placeholders(entry.master_value)

    if match_placeholders(master_matches, entry.value) do
      []
    else
      [
        %Message{
          check: :placeholder_count,
          text: entry.value
        }
      ]
    end
  end

  defp match_placeholders(placeholders, text) do
    Enum.reduce_while(placeholders, true, fn {regex, master_match}, _ ->
      if Enum.sort(Regex.scan(regex, text)) === Enum.sort(master_match) do
        {:cont, true}
      else
        {:halt, false}
      end
    end)
  end

  defp master_placeholders(text) do
    @regex
    |> Enum.map(&{&1, Regex.scan(&1, text)})
    |> Enum.reject(fn {_, match} -> Enum.empty?(match) end)
  end
end
