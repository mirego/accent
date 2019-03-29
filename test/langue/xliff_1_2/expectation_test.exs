defmodule LangueTest.Formatter.XLIFF12.Expectation do
  alias Langue.Entry

  defmodule Simple do
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
        </body>
      </file>
      """
    end

    def entries do
      [
        %Entry{key: "greeting", value: "bonjour", master_value: "hello", index: 1},
        %Entry{key: "goodbye", value: "À la prochaine", master_value: "Bye bye", index: 2}
      ]
    end
  end
end
