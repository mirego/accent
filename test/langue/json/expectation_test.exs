defmodule AccentTest.Formatter.Json.Expectation do
  alias Langue.Entry

  defmodule Empty do
    use Langue.Expectation.Case

    def render, do: "{\n  \n}\n"
    def entries, do: []
  end

  defmodule NilValue do
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
        %Entry{comment: "", index: 1, key: "test", value: "null", value_type: "null"}
      ]
    end
  end

  defmodule EmptyValue do
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
        %Entry{comment: "", index: 1, key: "test", value: "", value_type: "empty"}
      ]
    end
  end

  defmodule BooleanValue do
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
        %Entry{comment: "", index: 1, key: "test", value: "false", value_type: "boolean"},
        %Entry{comment: "", index: 2, key: "test2", value: "true", value_type: "boolean"}
      ]
    end
  end

  defmodule Simple do
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
        %Entry{comment: "", index: 1, key: "test", value: "F"},
        %Entry{comment: "", index: 2, key: "test2", value: "D"},
        %Entry{comment: "", index: 3, key: "test3", value: "New history please"}
      ]
    end
  end

  defmodule Nested do
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
        %Entry{comment: "", index: 1, key: "test.nested", value: "A"},
        %Entry{comment: "", index: 2, key: "test2.full.nested", value: "B"},
        %Entry{comment: "", index: 3, key: "test2.normal", value: "C"}
      ]
    end
  end

  defmodule Complexe do
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
                    "current_season_must_be_unique": "Les saisons ne doivent pas se chevaucher. Une seule saison à la fois."
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
        %Entry{comment: "", index: 1, key: "activerecord.errors.models.result.attributes.video_url.invalid_url", value: "n’est pas valide"},
        %Entry{
          comment: "",
          index: 2,
          key: "activerecord.errors.models.season.attributes.base.current_season_must_be_unique",
          value: "Les saisons ne doivent pas se chevaucher. Une seule saison à la fois."
        },
        %Entry{comment: "", index: 3, key: "activerecord.errors.models.season.attributes.starts_at.cant_be_changed", value: "ne peut pas être changé"},
        %Entry{comment: "", index: 4, key: "activerecord.errors.models.season.attributes.workouts_count.cant_be_changed", value: "ne peut pas être changé"},
        %Entry{comment: "", index: 5, key: "attributes.country_code", value: "Pays"},
        %Entry{comment: "", index: 6, key: "attributes.credit_card", value: "Carte de crédit"},
        %Entry{comment: "", index: 7, key: "attributes.email", value: "Courriel"},
        %Entry{comment: "", index: 8, key: "attributes.first_name", value: "Prénom"},
        %Entry{comment: "", index: 9, key: "attributes.last_name", value: "Nom"},
        %Entry{comment: "", index: 10, key: "attributes.package", value: "Forfait"},
        %Entry{comment: "", index: 11, key: "attributes.password", value: "Mot de passe"},
        %Entry{comment: "", index: 12, key: "attributes.seasons", value: "Saisons"},
        %Entry{comment: "", index: 13, key: "array_type.__KEY__0", value: "foo"},
        %Entry{comment: "", index: 14, key: "array_type.__KEY__1.bar", value: "baz"},
        %Entry{comment: "", index: 15, key: "array_type.__KEY__1.aux", value: "zoo"},
        %Entry{comment: "", index: 16, key: "array_type.__KEY__2.aa", value: "bb"},
        %Entry{comment: "", index: 17, key: "array_type.__KEY__2.cc", value: "dd"},
        %Entry{comment: "", index: 18, key: "array_type.__KEY__2.nested_array.__KEY__0", value: "null", value_type: "null"},
        %Entry{comment: "", index: 19, key: "array_type.__KEY__2.nested_array.__KEY__1", value: "two"}
      ]
    end
  end
end
