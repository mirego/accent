defmodule Langue.Utils.Interpolations do
  def parse(entries, regex) when is_list(entries), do: Enum.map(entries, &parse(&1, regex))

  def parse(entry, :not_supported), do: entry

  def parse(entry = %Langue.Entry{}, regex) do
    interpolations =
      regex
      |> Regex.scan(entry.value, capture: :first)
      |> List.flatten()

    %{entry | interpolations: interpolations}
  end
end
