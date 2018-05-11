defmodule Langue.Formatter.CSV.Serializer do
  @behaviour Langue.Formatter.Serializer

  def serialize(%{entries: entries}) do
    data =
      entries
      |> Stream.map(&to_list/1)
      |> CSV.encode()
      |> Enum.join()

    %Langue.Formatter.SerializerResult{render: data}
  end

  defp to_list(%{key: key, value: value}), do: [key, value]
end
