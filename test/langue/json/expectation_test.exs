defmodule LangueTest.Formatter.Json.Expectation do
  @moduledoc false
  alias Langue.Entry

  defmodule Empty do
    @moduledoc false
    use Langue.Expectation.Case

    def render, do: "{}\n"
    def entries, do: []
  end

  defmodule NilValue do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      {
        "test": null
      }
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "test", value: "null", value_type: "null"}
      ]
    end
  end

  defmodule EmptyValue do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      {
        "test": ""
      }
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "test", value: "", value_type: "empty"}
      ]
    end
  end

  defmodule BooleanValue do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      {
        "test": false,
        "test2": true
      }
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "test", value: "false", value_type: "boolean"},
        %Entry{index: 2, key: "test2", value: "true", value_type: "boolean"}
      ]
    end
  end

  defmodule FloatValue do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      {
        "test": 7.8
      }
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "test", value: "7.8", value_type: "float"}
      ]
    end
  end

  defmodule IntegerValue do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      {
        "test": 7
      }
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "test", value: "7", value_type: "integer"}
      ]
    end
  end

  defmodule InvalidIntegerValue do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      {
        "test": "something bad, fallback to string"
      }
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "test", value: "something bad, fallback to string", value_type: "integer"}
      ]
    end
  end

  defmodule InvalidFloatValue do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      {
        "test": "something bad, fallback to string"
      }
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "test", value: "something bad, fallback to string", value_type: "float"}
      ]
    end
  end

  defmodule Array do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      {
        "test": [
          {
            "a": "value-a"
          },
          {
            "b": "value-b"
          },
          {
            "c": "value-c"
          }
        ]
      }
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "test.__KEY__0.a", value: "value-a", value_type: "string"},
        %Entry{index: 2, key: "test.__KEY__1.b", value: "value-b", value_type: "string"},
        %Entry{index: 3, key: "test.__KEY__2.c", value: "value-c", value_type: "string"}
      ]
    end
  end

  defmodule Simple do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      {
        "test": "F",
        "test2": "D",
        "test3": "New history please"
      }
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "test", value: "F", value_type: "string"},
        %Entry{index: 2, key: "test2", value: "D", value_type: "string"},
        %Entry{index: 3, key: "test3", value: "New history please", value_type: "string"}
      ]
    end
  end

  defmodule Nested do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      {
        "test": {
          "nested": "A"
        },
        "test2": {
          "full": {
            "nested": "B"
          },
          "normal": "C"
        }
      }
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "test.nested", value: "A", value_type: "string"},
        %Entry{index: 2, key: "test2.full.nested", value: "B", value_type: "string"},
        %Entry{index: 3, key: "test2.normal", value: "C", value_type: "string"}
      ]
    end
  end

  defmodule Complexe do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      {
        "activerecord": {
          "errors": {
            "models": {
              "result": {
                "attributes": {
                  "video_url": {
                    "invalid_url": "n’est pas valide"
                  }
                }
              },
              "season": {
                "attributes": {
                  "base": {
                    "current_season_must_be_unique": "Les saisons"
                  },
                  "starts_at": {
                    "cant_be_changed": "ne peut pas être changé"
                  },
                  "workouts_count": {
                    "cant_be_changed": "ne peut pas être changé"
                  }
                }
              }
            }
          }
        },
        "attributes": {
          "country_code": "Pays",
          "credit_card": "Carte de crédit",
          "email": "Courriel",
          "first_name": "Prénom",
          "last_name": "Nom",
          "package": "Forfait",
          "password": "Mot de passe",
          "seasons": "Saisons"
        },
        "array_type": [
          "foo",
          {
            "bar": "baz",
            "aux": "zoo"
          },
          {
            "aa": "bb",
            "cc": "dd",
            "dd": "",
            "nested_array": [
              null,
              "two"
            ]
          }
        ]
      }
      """
    end

    def entries do
      [
        %Entry{
          index: 1,
          key: "activerecord.errors.models.result.attributes.video_url.invalid_url",
          value: "n’est pas valide",
          value_type: "string"
        },
        %Entry{
          index: 2,
          key: "activerecord.errors.models.season.attributes.base.current_season_must_be_unique",
          value: "Les saisons",
          value_type: "string"
        },
        %Entry{
          index: 3,
          key: "activerecord.errors.models.season.attributes.starts_at.cant_be_changed",
          value: "ne peut pas être changé",
          value_type: "string"
        },
        %Entry{
          index: 4,
          key: "activerecord.errors.models.season.attributes.workouts_count.cant_be_changed",
          value: "ne peut pas être changé",
          value_type: "string"
        },
        %Entry{index: 5, key: "attributes.country_code", value: "Pays", value_type: "string"},
        %Entry{index: 6, key: "attributes.credit_card", value: "Carte de crédit", value_type: "string"},
        %Entry{index: 7, key: "attributes.email", value: "Courriel", value_type: "string"},
        %Entry{index: 8, key: "attributes.first_name", value: "Prénom", value_type: "string"},
        %Entry{index: 9, key: "attributes.last_name", value: "Nom", value_type: "string"},
        %Entry{index: 10, key: "attributes.package", value: "Forfait", value_type: "string"},
        %Entry{index: 11, key: "attributes.password", value: "Mot de passe", value_type: "string"},
        %Entry{index: 12, key: "attributes.seasons", value: "Saisons", value_type: "string"},
        %Entry{index: 13, key: "array_type.__KEY__0", value: "foo", value_type: "string"},
        %Entry{index: 14, key: "array_type.__KEY__1.bar", value: "baz", value_type: "string"},
        %Entry{index: 15, key: "array_type.__KEY__1.aux", value: "zoo", value_type: "string"},
        %Entry{index: 16, key: "array_type.__KEY__2.aa", value: "bb", value_type: "string"},
        %Entry{index: 17, key: "array_type.__KEY__2.cc", value: "dd", value_type: "string"},
        %Entry{index: 18, key: "array_type.__KEY__2.dd", value: "", value_type: "empty"},
        %Entry{index: 19, key: "array_type.__KEY__2.nested_array.__KEY__0", value: "null", value_type: "null"},
        %Entry{index: 20, key: "array_type.__KEY__2.nested_array.__KEY__1", value: "two", value_type: "string"}
      ]
    end
  end

  defmodule PlaceholderValues do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      {
        "placeholders": {
          "single": "Hello, {{username}}.",
          "multiple": "Hello, {{firstname}} {{lastname}}.",
          "duplicate": "Hello, {{username}}. Welcome back {{username}}.",
          "empty": "Hello, {{}}."
        }
      }
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
