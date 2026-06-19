defmodule LangueTest.Formatter.XLIFF12.Expectation do
  @moduledoc false
  alias Langue.Entry
  alias Langue.Expectation.Case

  defmodule Simple do
    @moduledoc false
    use Case

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

  defmodule SymfonyFormat do
    @moduledoc false
    use Case

    def render do
      """
      <xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" version="1.2">
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
      </xliff>
      """
    end

    def entries do
      [
        %Entry{key: "greeting", value: "bonjour", master_value: "hello", index: 1, value_type: "string"},
        %Entry{key: "goodbye", value: "À la prochaine", master_value: "Bye bye", index: 2, value_type: "string"}
      ]
    end
  end

  defmodule HeaderAndBody do
    @moduledoc false
    use Case

    def render do
      """
      <file original="project-a" datatype="plaintext" source-language="en" target-language="fr">
        <header>
          <tool tool-id="symfony" tool-name="Symfony"/>
        </header>
        <body>
          <trans-unit id="greeting">
            <source>hello</source>
            <target>bonjour</target>
          </trans-unit>
        </body>
      </file>
      """
    end

    def entries do
      [
        %Entry{key: "greeting", value: "bonjour", master_value: "hello", index: 1, value_type: "string"}
      ]
    end
  end

  defmodule TransUnitWithNotes do
    @moduledoc false
    use Case

    def render do
      """
      <file original="project-a" datatype="plaintext" source-language="en" target-language="fr">
        <body>
          <trans-unit id="greeting" xml:space="preserve">
            <source>hello</source>
            <target>bonjour</target>
            <note>Greeting message</note>
          </trans-unit>
        </body>
      </file>
      """
    end

    def entries do
      [
        %Entry{key: "greeting", value: "bonjour", master_value: "hello", index: 1, value_type: "string"}
      ]
    end
  end

  defmodule ReorderedSourceTarget do
    @moduledoc false
    use Case

    def render do
      """
      <file original="project-a" datatype="plaintext" source-language="en" target-language="fr">
        <body>
          <trans-unit id="greeting">
            <target>bonjour</target>
            <source>hello</source>
          </trans-unit>
        </body>
      </file>
      """
    end

    def entries do
      [
        %Entry{key: "greeting", value: "bonjour", master_value: "hello", index: 1, value_type: "string"}
      ]
    end
  end
end
