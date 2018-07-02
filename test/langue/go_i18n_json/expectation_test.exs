defmodule LangueTest.Formatter.GoI18nJson.Expectation do
  alias Langue.Entry

  defmodule Simple do
    use Langue.Expectation.Case

    def render do
      """
      [
        {
          "id": "empty_string_translation",
          "translation": ""
        },
        {
          "id": "key_with_description",
          "translation": "Check it out!"
        },
        {
          "id": "key_with_line-break",
          "translation": "This translations contains\\na line-break."
        },
        {
          "id": "nested.key",
          "translation": "This key is nested inside a namespace."
        },
        {
          "id": "null_translation",
          "translation": null
        },
        {
          "id": "pluralized_key",
          "translation": {
            "one": "Only one pluralization found.",
            "other": "Wow, you have %s pluralizations!",
            "zero": "You have no pluralization."
          }
        }
      ]
      """
    end

    def entries do
      [
        %Entry{key: "empty_string_translation", value: "", value_type: "empty", comment: "", index: 1},
        %Entry{key: "key_with_description", value: "Check it out!", comment: "", index: 2},
        %Entry{key: "key_with_line-break", value: "This translations contains\na line-break.", comment: "", index: 3},
        %Entry{key: "nested.key", value: "This key is nested inside a namespace.", comment: "", index: 4},
        %Entry{key: "null_translation", value: "null", value_type: "null", comment: "", index: 5},
        %Entry{key: "pluralized_key.one", value: "Only one pluralization found.", comment: "", index: 6, plural: true},
        %Entry{key: "pluralized_key.other", value: "Wow, you have %s pluralizations!", comment: "", index: 7, plural: true},
        %Entry{key: "pluralized_key.zero", value: "You have no pluralization.", comment: "", index: 8, plural: true}
      ]
    end
  end
end
