defmodule LangueTest.Formatter.Android.Expectation do
  @moduledoc false
  alias Langue.Entry
  alias Langue.Expectation.Case

  defmodule Simple do
    @moduledoc false
    use Case

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

  defmodule Plural do
    @moduledoc false
    use Case

    def render do
      """
      <?xml version="1.0" encoding="utf-8"?>
      <resources>
        <plurals name="pluralized_key">
          <item quantity="one">Only one pluralization found.</item>
          <item quantity="other">Wow, you have %s pluralizations!</item>
          <item quantity="zero">You have no pluralization.</item>
        </plurals>
      </resources>
      """
    end

    def entries do
      [
        %Entry{
          index: 1,
          key: "pluralized_key.one",
          value: "Only one pluralization found.",
          value_type: "string",
          plural: true
        },
        %Entry{
          index: 2,
          key: "pluralized_key.other",
          value: "Wow, you have %@ pluralizations!",
          value_type: "string",
          plural: true,
          placeholders: ["%@"]
        },
        %Entry{
          index: 3,
          key: "pluralized_key.zero",
          value: "You have no pluralization.",
          value_type: "string",
          plural: true
        }
      ]
    end
  end

  defmodule EmptyValue do
    @moduledoc false
    use Case

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
    @moduledoc false
    use Case

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
    @moduledoc false
    use Case

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
    @moduledoc false
    use Case

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
        %Entry{
          index: 1,
          key: "activity_open_in_chrome",
          value: "Ouvrir avec Chrome",
          comment: " Comment ",
          value_type: "string"
        },
        %Entry{index: 2, key: "activity_open_in_safari", value: "Ouvrir avec Safari", value_type: "string"}
      ]
    end
  end

  defmodule Array do
    @moduledoc false
    use Case

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
        %Entry{
          index: 1,
          key: "drawer_menu_array.__KEY__0",
          value: "@string/browse_profile_view_title",
          value_type: "array"
        },
        %Entry{index: 2, key: "drawer_menu_array.__KEY__1", value: "@string/find_a_user", value_type: "array"}
      ]
    end
  end

  defmodule StringsFormatEscape do
    @moduledoc false
    use Case

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
        %Entry{
          index: 2,
          key: "agree_terms_policy",
          value: "By using this application, you agree to the %1$@ and %2$@.",
          placeholders: ~w(%1$@ %2$@),
          value_type: "string"
        }
      ]
    end
  end

  defmodule ValueEscaping do
    @moduledoc false
    use Case

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
    @moduledoc false
    use Case

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
        %Entry{
          index: 2,
          key: "multiple",
          value: "Hello, %1$@ %2$@.",
          placeholders: ~w(%1$@ %2$@),
          value_type: "string"
        },
        %Entry{
          index: 3,
          key: "duplicate",
          value: "Hello, %1$@ %2$@. Welcome back %1$@ %2$@.",
          placeholders: ~w(%1$@ %2$@ %1$@ %2$@),
          value_type: "string"
        }
      ]
    end
  end
end
