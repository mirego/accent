defmodule LangueTest.Formatter.Es6Module.Expectation do
  alias Langue.Entry

  defmodule Simple do
    use Langue.Expectation.Case

    def render do
      """
      export default {
        "general": {
          "nested": "value ok",
          "roles": {
            "owner": "Owner"
          }
        },
        "test": "OK"
      };
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "general.nested", value: "value ok"},
        %Entry{index: 2, key: "general.roles.owner", value: "Owner"},
        %Entry{index: 3, key: "test", value: "OK"}
      ]
    end
  end

  defmodule Plural do
    use Langue.Expectation.Case

    def render do
      """
      export default {
        "count_something": {
          "one": "1 item",
          "other": "{{count}} items",
          "zero": "No items"
        }
      };
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "count_something.one", value: "1 item", value_type: "string", plural: true},
        %Entry{index: 2, key: "count_something.other", value: "{{count}} items", value_type: "string", plural: true, interpolations: ~w({{count}})},
        %Entry{index: 3, key: "count_something.zero", value: "No items", value_type: "string", plural: true}
      ]
    end
  end

  defmodule InterpolationValues do
    use Langue.Expectation.Case

    def render do
      """
      export default {
        "interpolations": {
          "single": "Hello, {{username}}.",
          "multiple": "Hello, {{firstname}} {{lastname}}.",
          "duplicate": "Hello, {{username}}. Welcome back {{username}}.",
          "empty": "Hello, {{}}."
        }
      };
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "interpolations.single", value: "Hello, {{username}}.", interpolations: ~w({{username}})},
        %Entry{index: 2, key: "interpolations.multiple", value: "Hello, {{firstname}} {{lastname}}.", interpolations: ~w({{firstname}} {{lastname}})},
        %Entry{index: 3, key: "interpolations.duplicate", value: "Hello, {{username}}. Welcome back {{username}}.", interpolations: ~w({{username}} {{username}})},
        %Entry{index: 4, key: "interpolations.empty", value: "Hello, {{}}.", interpolations: ~w({{}})}
      ]
    end
  end
end
