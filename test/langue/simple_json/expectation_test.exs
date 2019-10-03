defmodule LangueTest.Formatter.SimpleJson.Expectation do
  alias Langue.Entry

  defmodule Empty do
    use Langue.Expectation.Case

    def render, do: "{}\n"
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
        %Entry{index: 1, key: "test", value: "F"},
        %Entry{index: 2, key: "test2", value: "D"},
        %Entry{index: 3, key: "test3", value: "New history please"},
        %Entry{index: 4, key: "test4.key", value: "value"}
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
        %Entry{index: 1, key: "test", value: "F"},
        %Entry{index: 2, key: "test2", value: "D"},
        %Entry{index: 3, key: "test3", value: "New history please"},
        %Entry{index: 4, key: "test4.key", value: "value"}
      ]
    end
  end

  defmodule PlaceholderValues do
    use Langue.Expectation.Case

    def render do
      """
      {
        "single": "Hello, {{username}}.",
        "multiple": "Hello, {{firstname}} {{lastname}}.",
        "duplicate": "Hello, {{username}}. Welcome back {{username}}.",
        "empty": "Hello, {{}}."
      }
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "single", value: "Hello, {{username}}.", placeholders: ~w({{username}})},
        %Entry{index: 2, key: "multiple", value: "Hello, {{firstname}} {{lastname}}.", placeholders: ~w({{firstname}} {{lastname}})},
        %Entry{index: 3, key: "duplicate", value: "Hello, {{username}}. Welcome back {{username}}.", placeholders: ~w({{username}} {{username}})},
        %Entry{index: 4, key: "empty", value: "Hello, {{}}.", placeholders: ~w({{}})}
      ]
    end
  end
end
