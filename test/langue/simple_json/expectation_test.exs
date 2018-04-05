defmodule AccentTest.Formatter.SimpleJson.Expectation do
  alias Langue.Entry

  defmodule Empty do
    use Langue.Expectation.Case

    def render, do: "{\n  \n}\n"
    def entries, do: []
  end

  defmodule SimpleParse do
    use Langue.Expectation.Case

    def render do
      """
      {
        "test": "F",
        "test2": "D",
        "test3": "New history please",
        "test4": {
          "key": "value"
        }
      }
      """
    end

    def entries do
      [
        %Entry{comment: "", index: 1, key: "test", value: "F"},
        %Entry{comment: "", index: 2, key: "test2", value: "D"},
        %Entry{comment: "", index: 3, key: "test3", value: "New history please"},
        %Entry{comment: "", index: 4, key: "test4.key", value: "value"}
      ]
    end
  end

  defmodule SimpleSerialize do
    use Langue.Expectation.Case

    def render do
      """
      {
        "test": "F",
        "test2": "D",
        "test3": "New history please",
        "test4.key": "value"
      }
      """
    end

    def entries do
      [
        %Entry{comment: "", index: 1, key: "test", value: "F"},
        %Entry{comment: "", index: 2, key: "test2", value: "D"},
        %Entry{comment: "", index: 3, key: "test3", value: "New history please"},
        %Entry{comment: "", index: 4, key: "test4.key", value: "value"}
      ]
    end
  end
end
