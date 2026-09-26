defmodule Langue.Formatter.XLIFF12.Parser do
  @moduledoc false
  @behaviour Langue.Formatter.Parser

  alias Langue.Entry
  alias Langue.Formatter.ParserResult
  alias Langue.Utils.Placeholders

  def parse(%{render: render}) do
    render
    |> :erlsom.simple_form([{:nameFun, fn name, _namespace, _prefix -> name end}])
    |> case do
      {:ok, root, _} ->
        case extract_body(root) do
          nil ->
            ParserResult.empty()

          body ->
            entries =
              body
              |> Enum.with_index(1)
              |> Enum.map(&parse_line/1)
              |> Enum.reject(&is_nil/1)
              |> Placeholders.parse(Langue.Formatter.XLIFF12.placeholder_regex())

            %ParserResult{entries: entries}
        end
    end
  end

  defp extract_body({~c"xliff", _, children}) do
    case Enum.find(children, &match?({~c"file", _, _}, &1)) do
      {~c"file", _, file_children} -> find_body(file_children)
      _ -> nil
    end
  end

  defp extract_body({~c"file", _, children}), do: find_body(children)
  defp extract_body(_), do: nil

  defp find_body(children) do
    case Enum.find(children, &match?({~c"body", _, _}, &1)) do
      {~c"body", _, body} -> body
      _ -> nil
    end
  end

  defp parse_line({{~c"trans-unit", attributes, children}, index}) do
    with {~c"id", key} <- List.keyfind(attributes, ~c"id", 0),
         {~c"source", _, source} <- Enum.find(children, &match?({~c"source", _, _}, &1)),
         {~c"target", _, value} <- Enum.find(children, &match?({~c"target", _, _}, &1)) do
      value = extract_text(value)
      source = extract_text(source)

      %Entry{
        value: value,
        master_value: source,
        value_type: Langue.ValueType.parse(value),
        key: IO.chardata_to_string(key),
        index: index
      }
    else
      _ -> nil
    end
  end

  defp parse_line(_), do: nil

  defp extract_text([value]), do: IO.chardata_to_string(value)
  defp extract_text(_), do: ""
end
