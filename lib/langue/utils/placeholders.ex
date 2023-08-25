defmodule Langue.Utils.Placeholders do
  @moduledoc false
  def parse(entries, regex) when is_list(entries), do: Enum.map(entries, &parse(&1, regex))

  def parse(entry, :not_supported), do: entry

  def parse(%Langue.Entry{} = entry, regex) do
    placeholders =
      regex
      |> Regex.scan(entry.value, capture: :first)
      |> List.flatten()

    %{entry | placeholders: placeholders}
  end
end
