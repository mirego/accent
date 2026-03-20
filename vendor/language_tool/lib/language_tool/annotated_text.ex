defmodule LanguageTool.AnnotatedText do
  @moduledoc false

  @html_regex ~r/<[^>]*>/
  @placeholder_regex ~r/[%$][a-zA-Z0-9]+/
  @empty_string_delimiter_regex ~r/\(""/

  def build(input, regex) do
    matches =
      Enum.concat([
        scan_entry_regex(input, regex),
        scan_html(input),
        scan_placeholders(input),
        scan_empty_strings_with_delimiter(input)
      ])

    matches = Enum.sort_by(matches, fn {match_index, _, _} -> match_index end)

    split_tokens(input, matches, 0, [])
  end

  defp scan_entry_regex(_input, nil), do: []
  defp scan_entry_regex(_input, :not_supported), do: []

  defp scan_entry_regex(input, regex) do
    regex
    |> Regex.scan(input, return: :index)
    |> List.flatten()
    |> Enum.map(fn {index, length} -> {index, length, "x"} end)
  end

  defp scan_empty_strings_with_delimiter(input) do
    @empty_string_delimiter_regex
    |> Regex.scan(input, return: :index)
    |> List.flatten()
    |> Enum.map(fn {index, length} -> {index, length, "(x"} end)
  end

  defp scan_html(input) do
    @html_regex
    |> Regex.scan(input, return: :index)
    |> List.flatten()
    |> Enum.map(fn {index, length} -> {index, length, ""} end)
  end

  defp scan_placeholders(input) do
    @placeholder_regex
    |> Regex.scan(input, return: :index)
    |> List.flatten()
    |> Enum.map(fn {index, length} -> {index, length, "x"} end)
  end

  defp split_tokens(input, [], position, acc) do
    case binary_slice(input, position..byte_size(input)) do
      text_after when byte_size(text_after) > 1 ->
        Enum.reverse(acc, [%{text: text_after}])

      _ ->
        Enum.reverse(acc)
    end
  end

  defp split_tokens(input, [{start_index, match_length, markup_as} | matches], position, acc) do
    acc =
      if position !== start_index and position < start_index do
        case binary_slice(input, position..(start_index - 1)) do
          "" -> acc
          text_before -> [%{text: text_before} | acc]
        end
      else
        acc
      end

    markup = binary_slice(input, start_index, match_length)

    split_tokens(
      input,
      matches,
      start_index + match_length,
      [%{markup: markup, markupAs: markup_as} | acc]
    )
  end
end
