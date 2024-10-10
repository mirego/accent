defmodule LangueTest.Formatter.SimpleJson.Expectation do
  @moduledoc false
  alias Langue.Entry
  alias Langue.Expectation.Case

  defmodule Empty do
    @moduledoc false
    use Case

    def render, do: "{}\n"
    def entries, do: []
  end

  defmodule SimpleParse do
    @moduledoc false
    use Case

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
        %Entry{index: 1, key: "test", value: "F", value_type: "string"},
        %Entry{index: 2, key: "test2", value: "D", value_type: "string"},
        %Entry{index: 3, key: "test3", value: "New history please", value_type: "string"},
        %Entry{index: 4, key: "test4.key", value: "value", value_type: "string"}
      ]
    end
  end

  defmodule SimpleSerialize do
    @moduledoc false
    use Case

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
        %Entry{index: 1, key: "test", value: "F", value_type: "string"},
        %Entry{index: 2, key: "test2", value: "D", value_type: "string"},
        %Entry{index: 3, key: "test3", value: "New history please", value_type: "string"},
        %Entry{index: 4, key: "test4.key", value: "value", value_type: "string"}
      ]
    end
  end

  defmodule PlaceholderValues do
    @moduledoc false
    use Case

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
        %Entry{
          index: 1,
          key: "single",
          value: "Hello, {{username}}.",
          placeholders: ~w({{username}}),
          value_type: "string"
        },
        %Entry{
          index: 2,
          key: "multiple",
          value: "Hello, {{firstname}} {{lastname}}.",
          placeholders: ~w({{firstname}} {{lastname}}),
          value_type: "string"
        },
        %Entry{
          index: 3,
          key: "duplicate",
          value: "Hello, {{username}}. Welcome back {{username}}.",
          placeholders: ~w({{username}} {{username}}),
          value_type: "string"
        },
        %Entry{index: 4, key: "empty", value: "Hello, {{}}.", placeholders: ~w({{}}), value_type: "string"}
      ]
    end
  end
end
