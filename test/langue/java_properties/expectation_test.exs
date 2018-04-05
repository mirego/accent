defmodule AccentTest.Formatter.JavaProperties.Expectation do
  alias Langue.Entry

  defmodule Simple do
    use Langue.Expectation.Case

    def render do
      """
      yes=Oui
      url.hello=Bonjour
      url.nested.ultra=I’m so nested
      url.normal=Normal string
      """
    end

    def entries do
      [
        %Entry{key: "yes", value: "Oui", comment: "", index: 1},
        %Entry{key: "url.hello", value: "Bonjour", comment: "", index: 2},
        %Entry{key: "url.nested.ultra", value: "I’m so nested", comment: "", index: 3},
        %Entry{key: "url.normal", value: "Normal string", comment: "", index: 4}
      ]
    end
  end
end
