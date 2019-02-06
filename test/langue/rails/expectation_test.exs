defmodule LangueTest.Formatter.Rails.Expectation do
  alias Langue.Entry

  defmodule NestedValues do
    use Langue.Expectation.Case

    def render do
      """
      "fr":
        "errors":
          "model":
            "user": "Utilisateur"
          "messages":
            "invalid_email": "n'est pas une adresse courriel valide"
            "invalid_url": "n'est pas un URL valide"
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "errors.model.user", value: "Utilisateur"},
        %Entry{index: 2, key: "errors.messages.invalid_email", value: "n'est pas une adresse courriel valide"},
        %Entry{index: 3, key: "errors.messages.invalid_url", value: "n'est pas un URL valide"}
      ]
    end
  end

  defmodule UnicodeValues do
    use Langue.Expectation.Case

    def render do
      """
      "fr":
        "errors":
          "model":
            "user": "éèàãô’ æ“"
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "errors.model.user", value: "éèàãô’ æ“"}
      ]
    end
  end

  defmodule EmptyValue do
    use Langue.Expectation.Case

    def render do
      """
      "fr":
        "test": ""
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "test", value: "", value_type: "empty"}
      ]
    end
  end

  defmodule IntegerValues do
    use Langue.Expectation.Case

    def render do
      """
      "fr":
        "count_somehting": 282
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "count_somehting", value: "282", value_type: "integer"}
      ]
    end
  end

  defmodule PluralValues do
    use Langue.Expectation.Case

    def render do
      """
      "fr":
        "count_something":
          "one": "1 item"
          "other": "%{count} items"
          "zero": "No items"
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "count_something.one", value: "1 item", value_type: "string", plural: true},
        %Entry{index: 2, key: "count_something.other", value: "%{count} items", value_type: "string", plural: true, placeholders: ~w(%{count})},
        %Entry{index: 3, key: "count_something.zero", value: "No items", value_type: "string", plural: true}
      ]
    end
  end

  defmodule ArrayValues do
    use Langue.Expectation.Case

    def render do
      """
      "fr":
        "errors":
          - "First error"
          - "Second error"
          -
            "nested":
              - "of course"
              -
                "nested_agin":
                  - "ok"
              - "it works"
        "root": "AWESOME"
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "errors.__KEY__0", value: "First error"},
        %Entry{index: 2, key: "errors.__KEY__1", value: "Second error"},
        %Entry{index: 3, key: "errors.__KEY__2.nested.__KEY__0", value: "of course"},
        %Entry{index: 4, key: "errors.__KEY__2.nested.__KEY__1.nested_agin.__KEY__0", value: "ok"},
        %Entry{index: 5, key: "errors.__KEY__2.nested.__KEY__2", value: "it works"},
        %Entry{index: 6, key: "root", value: "AWESOME"}
      ]
    end
  end

  defmodule PlaceholderValues do
    use Langue.Expectation.Case

    def render do
      """
      "fr":
        "placeholders":
          "single": "Hello, %{username}."
          "multiple": "Hello, %{firstname} %{lastname}."
          "duplicate": "Hello, %{username}. Welcome back %{username}."
          "empty": "Hello, %{}."
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "placeholders.single", value: "Hello, %{username}.", placeholders: ~w(%{username})},
        %Entry{index: 2, key: "placeholders.multiple", value: "Hello, %{firstname} %{lastname}.", placeholders: ~w(%{firstname} %{lastname})},
        %Entry{index: 3, key: "placeholders.duplicate", value: "Hello, %{username}. Welcome back %{username}.", placeholders: ~w(%{username} %{username})},
        %Entry{index: 4, key: "placeholders.empty", value: "Hello, %{}.", placeholders: ~w(%{})}
      ]
    end
  end
end
