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
        %Entry{index: 1, key: "activity_open_in_chrome", value: "Ouvrir avec Chrome", comment: ""},
        %Entry{index: 2, key: "activity_open_in_safari", value: "Ouvrir avec Safari", comment: ""}
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
        %Entry{index: 1, key: "activity_open_in_chrome", value: "", comment: "", value_type: "empty"}
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
        %Entry{index: 1, key: "activity_open_in_chrome", value: "Ouvrir avec Chrome", comment: " Comment "},
        %Entry{index: 2, key: "activity_open_in_safari", value: "Ouvrir avec Safari", comment: ""}
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
        %Entry{index: 1, key: "drawer_menu_array.__KEY__0", value: "@string/browse_profile_view_title", comment: "", value_type: "array"},
        %Entry{index: 2, key: "drawer_menu_array.__KEY__1", value: "@string/find_a_user", comment: "", value_type: "array"}
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
        %Entry{index: 1, key: "height", value: "Height (%@)", comment: ""},
        %Entry{index: 2, key: "agree_terms_policy", value: "By using this application, you agree to the %1$@ and %2$@.", comment: ""}
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
        %Entry{index: 1, key: "a", value: "Test & 1,2,4 < > j'appelle", comment: ""}
      ]
    end
  end
end
