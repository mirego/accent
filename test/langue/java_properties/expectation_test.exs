defmodule LangueTest.Formatter.JavaProperties.Expectation do
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
        %Entry{index: 1, key: "yes", value: "Oui"},
        %Entry{index: 2, key: "url.hello", value: "Bonjour"},
        %Entry{index: 3, key: "url.nested.ultra", value: "I’m so nested"},
        %Entry{index: 4, key: "url.normal", value: "Normal string"}
      ]
    end
  end

  defmodule InterpolationValues do
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
        %Entry{index: 1, key: "single", value: "${const:java.awt.event.KeyEvent.VK_CANCEL}", interpolations: ~w(${const:java.awt.event.KeyEvent.VK_CANCEL})},
        %Entry{index: 2, key: "multiple", value: "${single}, ${sys:user.home}/settings.xml", interpolations: ~w(${single} ${sys:user.home})},
        %Entry{index: 3, key: "duplicate", value: "${env:JAVA_HOME}, ${env:JAVA_HOME}!", interpolations: ~w(${env:JAVA_HOME} ${env:JAVA_HOME})},
        %Entry{index: 4, key: "empty", value: "Hello, ${}.", interpolations: ~w(${})}
      ]
    end
  end
end
