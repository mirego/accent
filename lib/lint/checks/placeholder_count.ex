defmodule Accent.Lint.Checks.PlaceholderCount do
  @moduledoc false
  @behaviour Accent.Lint.Check

  alias Accent.Lint.Message

  @regex Langue.placeholder_regex()

  @impl true
  def enabled?, do: true

  @impl true
  def applicable(entry), do: is_binary(entry.value) and not entry.is_master and is_binary(entry.master_value)

  @impl true
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
