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
        %Entry{key: "empty_string_translation", value: "", value_type: "empty", index: 1},
        %Entry{key: "key_with_description", value: "Check it out!", index: 2, value_type: "string"},
        %Entry{key: "key_with_line-break", value: "This translations contains\na line-break.", index: 3, value_type: "string"},
        %Entry{key: "nested.key", value: "This key is nested inside a namespace.", index: 4, value_type: "string"},
        %Entry{key: "null_translation", value: "null", value_type: "null", index: 5},
        %Entry{key: "pluralized_key.one", value: "Only one pluralization found.", index: 6, plural: true, value_type: "string"},
        %Entry{key: "pluralized_key.other", value: "Wow, you have %s pluralizations!", index: 7, plural: true, value_type: "string"},
        %Entry{key: "pluralized_key.zero", value: "You have no pluralization.", index: 8, plural: true, value_type: "string"}
      ]
    end
  end

  defmodule UTF8 do
    use Langue.Expectation.Case

    def render do
      """
      [
        {
          "id": "çà’èÈ",
          "translation": "àèéäâÇçò"
        }
      ]
      """
    end

    def entries do
      [
        %Entry{key: "çà’èÈ", value: "àèéäâÇçò", index: 1, value_type: "string"}
      ]
    end
  end
end
