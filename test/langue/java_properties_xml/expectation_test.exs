defmodule LangueTest.Formatter.JavaPropertiesXml.Expectation do
  alias Langue.Entry

  defmodule Simple do
    use Langue.Expectation.Case

    def render do
      """
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
      <properties>
        <!-- XML COMMENT -->
        <entry key="yes">Oui</entry>
        <entry key="url.hello">Bonjour</entry>
        <entry key="url.nested.ultra">I’m so nested</entry>
        <entry key="url.normal">Normal string</entry>
      </properties>
      """
    end

    def entries do
      [
        %Entry{key: "yes", value: "Oui", comment: "  <!-- XML COMMENT -->", index: 1},
        %Entry{key: "url.hello", value: "Bonjour", comment: "", index: 2},
        %Entry{key: "url.nested.ultra", value: "I’m so nested", comment: "", index: 3},
        %Entry{key: "url.normal", value: "Normal string", comment: "", index: 4}
      ]
    end
  end
end
