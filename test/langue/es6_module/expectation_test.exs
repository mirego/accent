defmodule LangueTest.Formatter.Es6Module.Expectation do
  @moduledoc false
  alias Langue.Entry
  alias Langue.Expectation.Case

  defmodule Simple do
    @moduledoc false
    use Case

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
        %Entry{index: 1, key: "general.nested", value: "value ok", value_type: "string"},
        %Entry{index: 2, key: "general.roles.owner", value: "Owner", value_type: "string"},
        %Entry{index: 3, key: "test", value: "OK", value_type: "string"}
      ]
    end
  end

  defmodule Plural do
    @moduledoc false
    use Case

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
        %Entry{
          index: 2,
          key: "count_something.other",
          value: "{{count}} items",
          value_type: "string",
          plural: true,
          placeholders: ~w({{count}})
        },
        %Entry{index: 3, key: "count_something.zero", value: "No items", value_type: "string", plural: true}
      ]
    end
  end

  defmodule PlaceholderValues do
    @moduledoc false
    use Case

    def render do
      """
      export default {
        "placeholders": {
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
        %Entry{
          index: 1,
          key: "placeholders.single",
          value: "Hello, {{username}}.",
          placeholders: ~w({{username}}),
          value_type: "string"
        },
        %Entry{
          index: 2,
          key: "placeholders.multiple",
          value: "Hello, {{firstname}} {{lastname}}.",
          placeholders: ~w({{firstname}} {{lastname}}),
          value_type: "string"
        },
        %Entry{
          index: 3,
          key: "placeholders.duplicate",
          value: "Hello, {{username}}. Welcome back {{username}}.",
          placeholders: ~w({{username}} {{username}}),
          value_type: "string"
        },
        %Entry{index: 4, key: "placeholders.empty", value: "Hello, {{}}.", placeholders: ~w({{}}), value_type: "string"}
      ]
    end
  end
end
