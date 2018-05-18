defmodule LangueTest.Formatter.Strings.Expectation do
  alias Langue.Entry

  defmodule Simple do
    use Langue.Expectation.Case

    def render do
      """
      "greeting" = "hello";
      "goodbye" = "Bye bye";
      """
    end

    def entries do
      [
        %Entry{key: "greeting", value: "hello", index: 1},
        %Entry{key: "goodbye", value: "Bye bye", index: 2}
      ]
    end
  end

  defmodule EmptyValue do
    use Langue.Expectation.Case

    def render do
      """
      "greeting" = "";
      "goodbye" = "Bye bye";
      """
    end

    def entries do
      [
        %Entry{key: "greeting", value: "", index: 1, value_type: "empty"},
        %Entry{key: "goodbye", value: "Bye bye", index: 2}
      ]
    end
  end

  defmodule Commented do
    use Langue.Expectation.Case

    def render do
      """
      /*
        Login text
      */
      "app.login.text" = "Enter your credentials below to login";

      /// Onboarding
      "app.login.text" = "Username";

      /* User state */
      "app.users.active" = "Just one user online";
      "app.users.unactive" = "No users online";
      """
    end

    def entries do
      [
        %Entry{key: "app.login.text", value: "Enter your credentials below to login", comment: "/*\n  Login text\n*/", index: 1},
        %Entry{key: "app.login.text", value: "Username", comment: "\n/// Onboarding", index: 2},
        %Entry{key: "app.users.active", value: "Just one user online", comment: "\n/* User state */", index: 3},
        %Entry{key: "app.users.unactive", value: "No users online", index: 4}
      ]
    end
  end

  defmodule Multiline do
    use Langue.Expectation.Case

    def render do
      """
      "app.feedback" = "
            Comment:
            \\n\\n\\n
            ---
            \\n\\nDevice information:
            \\n\\nDevice: BLA
      ";
      "app.login.text" = "Username";
      """
    end

    def entries do
      [
        %Entry{key: "app.feedback", value: "\n      Comment:\n      \\n\\n\\n\n      ---\n      \\n\\nDevice information:\n      \\n\\nDevice: BLA\n", index: 1},
        %Entry{key: "app.login.text", value: "Username", index: 2}
      ]
    end
  end

  defmodule InterpolationValues do
    use Langue.Expectation.Case

    def render do
      """
      "single" = "Hello, %s.";
      "multiple" = "Hello, %1$s %2$s.";
      "duplicate" = "Hello, %1$s %2$s. Welcome back %1$s %2$s.";
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "single", value: "Hello, %s.", interpolations: ~w(%s)},
        %Entry{index: 2, key: "multiple", value: "Hello, %1$s %2$s.", interpolations: ~w(%1$s %2$s)},
        %Entry{index: 3, key: "duplicate", value: "Hello, %1$s %2$s. Welcome back %1$s %2$s.", interpolations: ~w(%1$s %2$s %1$s %2$s)}
      ]
    end
  end
end
