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
        %Entry{key: "url.hello", value: "Bonjour", index: 2},
        %Entry{key: "url.nested.ultra", value: "I’m so nested", index: 3},
        %Entry{key: "url.normal", value: "Normal string", index: 4}
      ]
    end
  end

  defmodule PlaceholderValues do
    use Langue.Expectation.Case

    def render do
      """
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
      <properties>
        <entry key="single">${const:java.awt.event.KeyEvent.VK_CANCEL}</entry>
        <entry key="multiple">${single}, ${sys:user.home}/settings.xml</entry>
        <entry key="duplicate">${env:JAVA_HOME}, ${env:JAVA_HOME}!</entry>
        <entry key="empty">Hello, ${}.</entry>
      </properties>
      """
    end

    def entries do
      LangueTest.Formatter.JavaProperties.Expectation.PlaceholderValues.entries()
    end
  end
end
