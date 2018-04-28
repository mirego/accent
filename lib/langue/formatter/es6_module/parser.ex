defmodule Langue.Formatter.Es6Module.Parser do
  @behaviour Langue.Formatter.Parser

  alias Langue.Formatter.Json.Parser, as: JsonParser

  def name, do: "es_module"

  def parse(%{render: render}) do
    # Remove the first "export default" line
    # Reverse the list to have quick access to bottom of the file
    # Remove the last 2 lines (the line-break at the end and the closing "}" with the ";")
    # Add the first "{" removed in the "export default"
    # Add the last "{" removed in the "export default"
    # Put back in String
    entries =
      render
      |> String.split("\n")
      |> tl
      |> Enum.reverse()
      |> tl
      |> tl
      |> Kernel.++(["{"])
      |> Enum.reverse()
      |> Kernel.++(["}"])
      |> Enum.join("\n")
      |> JsonParser.parse_json()

    %Langue.Formatter.ParserResult{entries: entries}
  end
end
