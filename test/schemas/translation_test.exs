defmodule AccentTest.Translation do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Accent.Translation

  describe "maybe_natural_order_by/2" do
    test "sorts by key ascending with '.' after other characters" do
      translations = [
        %Translation{key: "a.foobar"},
        %Translation{key: "a-foobar"},
        %Translation{key: "a_foobar"},
        %Translation{key: "ab"},
        %Translation{key: "aa"}
      ]

      result = Translation.maybe_natural_order_by(translations, "key")
      keys = Enum.map(result, & &1.key)

      # '.' represents nesting so should sort after other chars at same level
      assert keys == ["a-foobar", "a_foobar", "aa", "ab", "a.foobar"]
    end

    test "sorts by key descending with '.' after other characters" do
      translations = [
        %Translation{key: "a.foobar"},
        %Translation{key: "a-foobar"},
        %Translation{key: "a_foobar"},
        %Translation{key: "ab"},
        %Translation{key: "aa"}
      ]

      result = Translation.maybe_natural_order_by(translations, "-key")
      keys = Enum.map(result, & &1.key)

      assert keys == ["a.foobar", "ab", "aa", "a_foobar", "a-foobar"]
    end

    test "nested keys sort after their parent siblings" do
      translations = [
        %Translation{key: "menu.file.open"},
        %Translation{key: "menu.file"},
        %Translation{key: "menu-item"},
        %Translation{key: "menu.edit"},
        %Translation{key: "menu"}
      ]

      result = Translation.maybe_natural_order_by(translations, "key")
      keys = Enum.map(result, & &1.key)

      # menu-item should come before any menu.* nested keys
      assert keys == ["menu", "menu-item", "menu.edit", "menu.file", "menu.file.open"]
    end

    test "returns translations unchanged for non-key ordering" do
      translations = [
        %Translation{key: "z"},
        %Translation{key: "a"}
      ]

      result = Translation.maybe_natural_order_by(translations, "updated_at")

      assert result == translations
    end
  end
end
