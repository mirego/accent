defmodule LanguageTool.AnnotatedText do
  @moduledoc false
  def build(input, regex) do
    matches = if regex, do: Regex.scan(regex, input, return: :index), else: []
    # Ignore HTML
    matches = matches ++ Regex.scan(~r/<[^>]*>/, input, return: :index)
    # Ignore % and $ often used as placeholders
    matches = matches ++ Regex.scan(~r/[%$][\w\d]+/, input, return: :index)
    matches = Enum.sort_by(matches, fn [{match_index, _}] -> match_index end)

    split_tokens(input, matches, 0, [])
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

  defp split_tokens(input, [[{start_index, match_length}] | matches], position, acc) do
    text_before =
      if position !== start_index do
        case binary_slice(input, position..(start_index - 1)) do
          "" -> []
          text_before -> [%{text: String.trim_leading(text_before)}]
        end
      else
        []
      end

    markup = binary_slice(input, start_index, match_length)
    split_tokens(input, matches, start_index + match_length, acc ++ text_before ++ [%{markup: markup}])
  end
end
