defmodule Langue.Formatter.CSV.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Formatter.ParserResult, as: Output
  alias Langue.Formatter.SerializerResult, as: Input
  alias Langue.Utils.Placeholders

  @spec parse(Input.t()) :: Output.t()
  def parse(%Input{render: input}) do
    entries =
      input
      |> String.split("\n", trim: true)
      |> CSV.decode!()
      |> Stream.with_index(1)
      |> Enum.map(&to_entry/1)
      |> Placeholders.parse(Langue.Formatter.CSV.placeholder_regex())

    %Output{entries: entries}
  end

  defp to_entry({[key, value], index}) do
    %Langue.Entry{
      index: index,
      key: key,
      value: value,
      value_type: Langue.ValueType.parse(value)
    }
  end
end
