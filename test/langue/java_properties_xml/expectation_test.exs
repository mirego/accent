defmodule LangueTest.Formatter.JavaPropertiesXml.Expectation do
  @moduledoc false
  alias Langue.Entry

  defmodule Simple do
    @moduledoc false
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
        %Entry{key: "yes", value: "Oui", comment: "  <!-- XML COMMENT -->", index: 1, value_type: "string"},
        %Entry{key: "url.hello", value: "Bonjour", index: 2, value_type: "string"},
        %Entry{key: "url.nested.ultra", value: "I’m so nested", index: 3, value_type: "string"},
        %Entry{key: "url.normal", value: "Normal string", index: 4, value_type: "string"}
      ]
    end
  end

  defmodule PlaceholderValues do
    @moduledoc false
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
      [
        %Entry{
          index: 1,
          key: "single",
          value: "${const:java.awt.event.KeyEvent.VK_CANCEL}",
          placeholders: ~w(${const:java.awt.event.KeyEvent.VK_CANCEL}),
          value_type: "string"
        },
        %Entry{
          index: 2,
          key: "multiple",
          value: "${single}, ${sys:user.home}/settings.xml",
          placeholders: ~w(${single} ${sys:user.home}),
          value_type: "string"
        },
        %Entry{
          index: 3,
          key: "duplicate",
          value: "${env:JAVA_HOME}, ${env:JAVA_HOME}!",
          placeholders: ~w(${env:JAVA_HOME} ${env:JAVA_HOME}),
          value_type: "string"
        },
        %Entry{index: 4, key: "empty", value: "Hello, ${}.", placeholders: ~w(${}), value_type: "string"}
      ]
    end
  end
end
