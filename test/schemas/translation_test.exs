defmodule AccentTest.Translation do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Accent.Translation

  describe "settings_changeset/2" do
    test "casts all settings fields" do
      translation = %Translation{}

      changeset =
        Translation.settings_changeset(translation, %{
          plural: true,
          locked: true,
          placeholders: ["count"],
          file_index: 3,
          file_comment: "a comment",
          value_type: "boolean",
          source_translation_id: Ecto.UUID.generate()
        })

      assert changeset.valid?
      assert changeset.changes.plural == true
      assert changeset.changes.locked == true
      assert changeset.changes.placeholders == ["count"]
      assert changeset.changes.file_index == 3
      assert changeset.changes.file_comment == "a comment"
      assert changeset.changes.value_type == "boolean"
      assert changeset.changes.source_translation_id
    end

    test "ignores fields outside whitelist" do
      translation = %Translation{}

      changeset =
        Translation.settings_changeset(translation, %{
          corrected_text: "should be ignored",
          conflicted: true,
          locked: true
        })

      assert changeset.valid?
      assert changeset.changes == %{locked: true}
    end

    test "valid with empty params" do
      translation = %Translation{}
      changeset = Translation.settings_changeset(translation, %{})

      assert changeset.valid?
      assert changeset.changes == %{}
    end
  end

  describe "maybe_natural_order_by/2" do
    test "sorts by key ascending with '.' before other characters" do
      translations = [
        %Translation{key: "a.foobar"},
        %Translation{key: "a-foobar"},
        %Translation{key: "a_foobar"},
        %Translation{key: "ab"},
        %Translation{key: "aa"}
      ]

      result = Translation.maybe_natural_order_by(translations, "key")
      keys = Enum.map(result, & &1.key)

      assert keys == ["a.foobar", "a-foobar", "a_foobar", "aa", "ab"]
    end

    test "sorts by key descending with '.' before other characters" do
      translations = [
        %Translation{key: "a.foobar"},
        %Translation{key: "a-foobar"},
        %Translation{key: "a_foobar"},
        %Translation{key: "ab"},
        %Translation{key: "aa"}
      ]

      result = Translation.maybe_natural_order_by(translations, "-key")
      keys = Enum.map(result, & &1.key)

      assert keys == ["ab", "aa", "a_foobar", "a-foobar", "a.foobar"]
    end

    test "nested keys sort before their parent siblings" do
      translations = [
        %Translation{key: "menu.file.open"},
        %Translation{key: "menu.file"},
        %Translation{key: "menu-item"},
        %Translation{key: "menu.edit"},
        %Translation{key: "menu"}
      ]

      result = Translation.maybe_natural_order_by(translations, "key")
      keys = Enum.map(result, & &1.key)

      assert keys == ["menu", "menu.edit", "menu.file", "menu.file.open", "menu-item"]
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
