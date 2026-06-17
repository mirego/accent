defmodule LangueTest.Formatter.RailsYml.Expectation do
  @moduledoc false
  alias Langue.Entry
  alias Langue.Expectation.Case

  defmodule Empty do
    @moduledoc false
    use Case

    def render, do: "---\nfr: {}\n"
    def entries, do: []
  end

  defmodule Simple do
    @moduledoc false
    use Case

    def render do
      """
      ---
      fr:
        hello: world
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "hello", value: "world", value_type: "string"}
      ]
    end
  end

  defmodule Nested do
    @moduledoc false
    use Case

    def render do
      """
      ---
      fr:
        a:
          b: c
          d: e
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "a.b", value: "c", value_type: "string"},
        %Entry{index: 2, key: "a.d", value: "e", value_type: "string"}
      ]
    end
  end

  defmodule Types do
    @moduledoc false
    use Case

    def render do
      """
      ---
      fr:
        b: true
        e: ''
        f: 7.8
        i: 7
        'n':
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "b", value: "true", value_type: "boolean"},
        %Entry{index: 2, key: "e", value: "", value_type: "empty"},
        %Entry{index: 3, key: "f", value: "7.8", value_type: "float"},
        %Entry{index: 4, key: "i", value: "7", value_type: "integer"},
        %Entry{index: 5, key: "n", value: "null", value_type: "null"}
      ]
    end
  end

  defmodule Array do
    @moduledoc false
    use Case

    def render do
      """
      ---
      fr:
        days:
          - Sun
          - Mon
          - Tue
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "days.__KEY__0", value: "Sun", value_type: "string"},
        %Entry{index: 2, key: "days.__KEY__1", value: "Mon", value_type: "string"},
        %Entry{index: 3, key: "days.__KEY__2", value: "Tue", value_type: "string"}
      ]
    end
  end

  defmodule PlaceholderValues do
    @moduledoc false
    use Case

    def render do
      """
      ---
      fr:
        greet: Hello %{name}
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "greet", value: "Hello %{name}", value_type: "string", placeholders: ["%{name}"]}
      ]
    end
  end
end
