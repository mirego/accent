defmodule LanguageTool.AnnotatedText do
  @moduledoc false
  def build(input, regex) do
    matches = scan_entry_regex(input, regex)
    # Ignore HTML
    matches = matches ++ scan_html(input)
    # Ignore % and $ often used as placeholders
    matches = matches ++ scan_placeholders(input)

    matches = Enum.sort_by(matches, fn {match_index, _, _} -> match_index end)

    split_tokens(input, matches, 0, [])
  end

  defp scan_entry_regex(_input, nil), do: []

  defp scan_entry_regex(input, regex) do
    regex
    |> Regex.scan(input, return: :index)
    |> List.flatten()
    |> Enum.map(fn {index, length} -> {index, length, "x"} end)
  end

  defp scan_html(input) do
    ~r/<[^>]*>/
    |> Regex.scan(input, return: :index)
    |> List.flatten()
    |> Enum.map(fn {index, length} -> {index, length, ""} end)
  end

  defp scan_placeholders(input) do
    ~r/[%$][a-zA-Z0-9]+/
    |> Regex.scan(input, return: :index)
    |> List.flatten()
    |> Enum.map(fn {index, length} -> {index, length, "x"} end)
  end

  defp split_tokens(input, [], position, acc) do
    to_add =
      case binary_slice(input, position..byte_size(input)) do
        text_after when byte_size(text_after) > 1 ->
          [%{text: text_after}]

        _ ->
          []
      end

    acc ++ to_add
  end

  defp split_tokens(input, [{start_index, match_length, markup_as} | matches], position, acc) do
    text_before =
      if position !== start_index and position < start_index do
        case binary_slice(input, position..(start_index - 1)) do
          "" -> []
          text_before -> [%{text: text_before}]
        end
      else
        []
      end

    markup = binary_slice(input, start_index, match_length)

    split_tokens(
      input,
      matches,
      start_index + match_length,
      acc ++ text_before ++ [%{markup: markup, markupAs: markup_as}]
    )
  end
end
