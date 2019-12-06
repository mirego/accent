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

  defmodule MultipleFile do
    use Langue.Expectation.Case

    def render do
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.2" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd">
        <file original="XApp/Base.lproj/LaunchScreen.storyboard" source-language="en" target-language="fr" datatype="plaintext">
          <header>
            <tool tool-id="com.apple.dt.xcode" tool-name="Xcode" tool-version="10.2.1" build-num="10E1001"/>
          </header>
          <body>
            <trans-unit id="greeting">
              <source>hello</source>
              <target>bonjour</target>
              <note>Class = "UILabel"; text = "XApp"; ObjectID = "hello";</note>
            </trans-unit>
          </body>
        </file>
        <file original="XApp/Base.lproj/Main.storyboard" source-language="en" target-language="fr" datatype="plaintext">
          <header>
            <tool tool-id="com.apple.dt.xcode" tool-name="Xcode" tool-version="10.2.1" build-num="10E1001"/>
          </header>
          <body>
            <trans-unit id="goodbye">
              <source>Bye bye</source>
              <target>À la prochaine</target>
            </trans-unit>
            <trans-unit id="hi">
              <source>Hi</source>
              <target>Salut</target>
            </trans-unit>
          </body>
        </file>
      </xliff>
      """
    end

    def entries do
      [
        %Entry{key: "greeting", value: "bonjour", master_value: "hello", comment: "Class = \"UILabel\"; text = \"XApp\"; ObjectID = \"hello\";", index: 1, file: "XApp/Base.lproj/LaunchScreen.storyboard"},
        %Entry{key: "goodbye", value: "À la prochaine", master_value: "Bye bye", index: 2, file: "XApp/Base.lproj/Main.storyboard"},
        %Entry{key: "hi", value: "Salut", master_value: "Hi", index: 3, file: "XApp/Base.lproj/Main.storyboard"}
      ]
    end
  end
end
