defmodule Langue.Formatter.JavaProperties.Parser do
  @moduledoc false
  @behaviour Langue.Formatter.Parser

  alias Langue.Utils.LineByLineHelper
  alias Langue.Utils.Placeholders

  @prop_line_regex ~r/^(?<key>.+)=(?<value>.*)$/

  def parse(%{render: render}) do
    entries =
      render
      |> LineByLineHelper.Parser.lines(@prop_line_regex)
      |> Placeholders.parse(Langue.Formatter.JavaProperties.placeholder_regex())

    %Langue.Formatter.ParserResult{entries: entries}
  end
end
