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
            "invalid_email": "n’est pas une adresse courriel valide"
            "invalid_url": "n’est pas un URL valide"
      """
    end

    def entries do
      [
        %Entry{comment: "", index: 1, key: "errors.model.user", value: "Utilisateur"},
        %Entry{comment: "", index: 2, key: "errors.messages.invalid_email", value: "n’est pas une adresse courriel valide"},
        %Entry{comment: "", index: 3, key: "errors.messages.invalid_url", value: "n’est pas un URL valide"}
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
        %Entry{comment: "", index: 1, key: "test", value: "", value_type: "empty"}
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
        %Entry{comment: "", index: 1, key: "count_somehting", value: "282", value_type: "integer"}
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
        %Entry{comment: "", index: 1, key: "count_something.one", value: "1 item", value_type: "string", plural: true},
        %Entry{comment: "", index: 2, key: "count_something.other", value: "%{count} items", value_type: "string", plural: true},
        %Entry{comment: "", index: 3, key: "count_something.zero", value: "No items", value_type: "string", plural: true}
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
        %Entry{comment: "", index: 1, key: "errors.__KEY__0", value: "First error"},
        %Entry{comment: "", index: 2, key: "errors.__KEY__1", value: "Second error"},
        %Entry{comment: "", index: 3, key: "errors.__KEY__2.nested.__KEY__0", value: "of course"},
        %Entry{comment: "", index: 4, key: "errors.__KEY__2.nested.__KEY__1.nested_agin.__KEY__0", value: "ok"},
        %Entry{comment: "", index: 5, key: "errors.__KEY__2.nested.__KEY__2", value: "it works"},
        %Entry{comment: "", index: 6, key: "root", value: "AWESOME"}
      ]
    end
  end
end
