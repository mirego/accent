defmodule Langue.Formatter.Csv.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Formatter.SerializerResult, as: Input
  alias Langue.Formatter.ParserResult, as: Output

  def name, do: "csv"

  @spec parse(Input.t()) :: Output.t()
  def parse(%Input{render: input}) do
    entries =
      input
      |> String.split("\n", trim: true)
      |> CSV.decode!()
      |> Stream.with_index(1)
      |> Enum.map(&to_entry/1)

    %Output{entries: entries}
  end

  defp to_entry({[key, value], idx}) do
    %Langue.Entry{index: idx, key: key, value: value}
  end
end
