defmodule LangueTest.Formatter.JavaProperties.Expectation do
  @moduledoc false
  alias Langue.Entry

  defmodule Simple do
    @moduledoc false
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
        %Entry{index: 1, key: "yes", value: "Oui", value_type: "string"},
        %Entry{index: 2, key: "url.hello", value: "Bonjour", value_type: "string"},
        %Entry{index: 3, key: "url.nested.ultra", value: "I’m so nested", value_type: "string"},
        %Entry{index: 4, key: "url.normal", value: "Normal string", value_type: "string"}
      ]
    end
  end

  defmodule PlaceholderValues do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      single=${const:java.awt.event.KeyEvent.VK_CANCEL}
      multiple=${single}, ${sys:user.home}/settings.xml
      duplicate=${env:JAVA_HOME}, ${env:JAVA_HOME}!
      empty=Hello, ${}.
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
