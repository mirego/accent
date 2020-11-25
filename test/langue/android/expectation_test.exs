defmodule LangueTest.Formatter.Android.Expectation do
  alias Langue.Entry

  defmodule Simple do
    use Langue.Expectation.Case

    def render do
      """
      <?xml version="1.0" encoding="utf-8"?>
      <resources>
        <string name="activity_open_in_chrome">Ouvrir avec Chrome</string>
        <string name="activity_open_in_safari">Ouvrir avec Safari</string>
      </resources>
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "activity_open_in_chrome", value: "Ouvrir avec Chrome", value_type: "string"},
        %Entry{index: 2, key: "activity_open_in_safari", value: "Ouvrir avec Safari", value_type: "string"}
      ]
    end
  end

  defmodule EmptyValue do
    use Langue.Expectation.Case

    def render do
      """
      <?xml version="1.0" encoding="utf-8"?>
      <resources>
        <string name="activity_open_in_chrome"></string>
      </resources>
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "activity_open_in_chrome", value: "", value_type: "empty"}
      ]
    end
  end

  defmodule UnsupportedTag do
    use Langue.Expectation.Case

    def render do
      """
      <?xml version="1.0" encoding="utf-8"?>
      <resources>
        <unknown name="activity_open_in_chrome"></unknown>
      </resources>
      """
    end

    def entries do
      []
    end
  end

  defmodule RuntimeError do
    use Langue.Expectation.Case

    def render do
      """
      <?xml version="1.0" encoding="utf-8"?>
      <error></error>
      """
    end

    def entries do
      []
    end
  end

  defmodule Commented do
    use Langue.Expectation.Case

    def render do
      """
      <?xml version="1.0" encoding="utf-8"?>
      <resources>
        <!-- Comment -->
        <string name="activity_open_in_chrome">Ouvrir avec Chrome</string>
        <string name="activity_open_in_safari">Ouvrir avec Safari</string>
      </resources>
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "activity_open_in_chrome", value: "Ouvrir avec Chrome", comment: " Comment ", value_type: "string"},
        %Entry{index: 2, key: "activity_open_in_safari", value: "Ouvrir avec Safari", value_type: "string"}
      ]
    end
  end

  defmodule Array do
    use Langue.Expectation.Case

    def render do
      """
      <?xml version="1.0" encoding="utf-8"?>
      <resources>
        <string-array name="drawer_menu_array">
          <item>@string/browse_profile_view_title</item>
          <item>@string/find_a_user</item>
        </string-array>
      </resources>
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "drawer_menu_array.__KEY__0", value: "@string/browse_profile_view_title", value_type: "array"},
        %Entry{index: 2, key: "drawer_menu_array.__KEY__1", value: "@string/find_a_user", value_type: "array"}
      ]
    end
  end

  defmodule StringsFormatEscape do
    use Langue.Expectation.Case

    def render do
      """
      <?xml version="1.0" encoding="utf-8"?>
      <resources>
        <string name="height">Height (%s)</string>
        <string name="agree_terms_policy">By using this application, you agree to the %1$s and %2$s.</string>
      </resources>
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "height", value: "Height (%@)", placeholders: ~w(%@), value_type: "string"},
        %Entry{index: 2, key: "agree_terms_policy", value: "By using this application, you agree to the %1$@ and %2$@.", placeholders: ~w(%1$@ %2$@), value_type: "string"}
      ]
    end
  end

  defmodule ValueEscaping do
    use Langue.Expectation.Case

    def render do
      """
      <?xml version="1.0" encoding="utf-8"?>
      <resources>
        <string name="a">Test &amp; 1,2,4 &lt; &gt; j\\'appelle</string>
      </resources>
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "a", value: "Test & 1,2,4 < > j'appelle", value_type: "string"}
      ]
    end
  end

  defmodule PlaceholderValues do
    use Langue.Expectation.Case

    def render do
      """
      <?xml version="1.0" encoding="utf-8"?>
      <resources>
        <string name="single">Hello, %s.</string>
        <string name="multiple">Hello, %1$s %2$s.</string>
        <string name="duplicate">Hello, %1$s %2$s. Welcome back %1$s %2$s.</string>
      </resources>
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "single", value: "Hello, %@.", placeholders: ~w(%@), value_type: "string"},
        %Entry{index: 2, key: "multiple", value: "Hello, %1$@ %2$@.", placeholders: ~w(%1$@ %2$@), value_type: "string"},
        %Entry{index: 3, key: "duplicate", value: "Hello, %1$@ %2$@. Welcome back %1$@ %2$@.", placeholders: ~w(%1$@ %2$@ %1$@ %2$@), value_type: "string"}
      ]
    end
  end
end
