defmodule Langue.Formatter.CSV.ExpectationTest do
  alias Langue.Entry

  defmodule Simple do
    use Langue.Expectation.Case

    def render do
      """
      a,b\r
      c,d\r
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "a", value: "b"},
        %Entry{index: 2, key: "c", value: "d"}
      ]
    end
  end
end
