defmodule LangueTest.Formatter.XLIFF12.Expectation do
  @moduledoc false
  alias Langue.Entry

  defmodule Simple do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      <file original="project-a" datatype="plaintext" source-language="en" target-language="fr">
        <body>
          <trans-unit id="greeting">
            <source>hello</source>
            <target>bonjour</target>
          </trans-unit>
          <trans-unit id="goodbye">
            <source>Bye bye</source>
            <target>À la prochaine</target>
          </trans-unit>
          <trans-unit id="empty">
            <source></source>
            <target></target>
          </trans-unit>
        </body>
      </file>
      """
    end

    def entries do
      [
        %Entry{key: "greeting", value: "bonjour", master_value: "hello", index: 1, value_type: "string"},
        %Entry{key: "goodbye", value: "À la prochaine", master_value: "Bye bye", index: 2, value_type: "string"},
        %Entry{key: "empty", value: "", master_value: "", index: 3, value_type: "empty"}
      ]
    end
  end
end
