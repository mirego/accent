defmodule Langue.Formatter.Laravel.Parser do
  @behaviour Langue.Formatter.Parser

  @php_assoc_regex ~r{["'](.*?)["']=>["'](.*?)["']}
  @assoc_key_index 1
  @assoc_value_index 2

  alias Langue.Utils.NestedParserHelper

  @typedoc """
  Key value tuple for matching translated text with his slug
  """
  @type raw_entry :: [String.t()]

  @typedoc """
  Entries as read from the PHP file
  """
  @type file_content :: [raw_entry]

  @typedoc """
  Key value tuple for matching translated text with his slug
  """
  @type entry :: {String.t(), String.t()}

  def parse(%{render: render}) do
    entries =
      render
      |> split_file
      |> as_tuples([])
      |> NestedParserHelper.parse()

    %Langue.Formatter.ParserResult{entries: entries}
  end

  @spec as_tuples(file_content, [entry]) :: [entry]
  def as_tuples(entries, tuples) when length(tuples) == length(entries), do: tuples

  def as_tuples(entries, tuples) do
    current_index = length(tuples)
    new_tuples = tuples ++ [entry_to_tuple(Enum.at(entries, current_index))]
    as_tuples(entries, new_tuples)
  end

  @spec entry_to_tuple(raw_entry) :: entry
  def entry_to_tuple(entry) do
    key = Enum.at(entry, @assoc_key_index)
    value = Enum.at(entry, @assoc_value_index)
    {key, value}
  end

  @spec split_file(String.t()) :: file_content
  def split_file(content) do
    Regex.scan(@php_assoc_regex, content)
  end
end
