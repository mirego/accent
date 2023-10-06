defmodule AccentTest.Lint do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Accent.Lint
  alias Accent.Lint.Message
  alias Accent.Lint.Replacement
  alias Langue.Entry

  describe "lint/2" do
    test "lint valid entry" do
      entry = %Entry{key: "a", value: "foo", master_value: "foo", value_type: "string"}
      [{_, messages}] = Lint.lint([entry])

      assert messages === []
    end

    test "lint placeholder simple" do
      entry = %Entry{key: "a", value: "nothing", is_master: false, master_value: "{{bar}}", value_type: "string"}
      [{_, messages}] = Lint.lint([entry])

      assert messages === [%Accent.Lint.Message{check: :placeholder_count, replacement: nil, text: "nothing"}]
    end

    test "lint placeholder many placeholders" do
      entry = %Entry{key: "a", value: "${{bar}}M {{bax}}da", master_value: "{{bar}} M$ {{bax}}", value_type: "string"}
      [{_, messages}] = Lint.lint([entry])

      assert messages === []
    end

    test "lint placeholder special chars" do
      entry = %Entry{key: "a", value: "${{bar}}M", master_value: "{{bar}} M$", value_type: "string"}
      [{_, messages}] = Lint.lint([entry])

      assert messages === []
    end

    test "lint trailing space entry" do
      entry = %Entry{key: "a", value: "foo ", master_value: "foo", value_type: "string"}
      [{_, messages}] = Lint.lint([entry])

      assert messages === [
               %Message{
                 replacement: %Replacement{value: "foo", label: "foo"},
                 check: :trailing_space,
                 text: "foo "
               }
             ]
    end

    test "lint apostrophe as single quote entry" do
      entry = %Entry{key: "a", value: "L'hiver", master_value: "", value_type: "string", language_slug: "fr"}
      [{_, messages}] = Lint.lint([entry])

      assert messages === [
               %Message{
                 replacement: %Replacement{value: "L’hiver", label: "L’hiver"},
                 check: :apostrophe_as_single_quote,
                 text: "L'hiver"
               }
             ]
    end

    test "lint three dots ellipsis entry" do
      entry = %Entry{key: "a", value: "foo...", master_value: "foo...", value_type: "string"}
      [{_, messages}] = Lint.lint([entry])

      assert messages === [
               %Message{
                 replacement: %Replacement{value: "foo…", label: "foo…"},
                 check: :three_dots_ellipsis,
                 text: "foo..."
               }
             ]
    end

    test "lint first letter uppercase entry" do
      entry = %Entry{key: "a", is_master: false, value: "bar", master_value: "Foo", value_type: "string"}
      [{_, messages}] = Lint.lint([entry])

      assert messages === [
               %Message{
                 replacement: %Replacement{value: "Bar", label: "Bar"},
                 check: :first_letter_case,
                 text: "bar"
               }
             ]
    end

    test "lint correct first letter accent uppercase entry" do
      entry = %Entry{key: "a", is_master: false, value: "Éar", master_value: "Foo", value_type: "string"}
      [{_, messages}] = Lint.lint([entry])

      assert messages === []
    end

    test "lint not applicable first letter non latin uppercase entry" do
      entry = %Entry{key: "a", is_master: false, value: "超级有趣", master_value: "Foo", value_type: "string"}
      [{_, messages}] = Lint.lint([entry])

      assert messages === []
    end

    test "lint incorrect first letter accent uppercase entry" do
      entry = %Entry{key: "a", is_master: false, value: "Éar", master_value: "foo", value_type: "string"}
      [{_, messages}] = Lint.lint([entry])

      assert messages === [
               %Message{
                 replacement: %Replacement{value: "éar", label: "éar"},
                 check: :first_letter_case,
                 text: "Éar"
               }
             ]
    end

    test "lint correct first letter accent downcase entry" do
      entry = %Entry{key: "a", is_master: false, value: "éar", master_value: "foo", value_type: "string"}
      [{_, messages}] = Lint.lint([entry])

      assert messages === []
    end

    test "lint incorrect first letter accent downcase entry" do
      entry = %Entry{key: "a", is_master: false, value: "éar", master_value: "Foo", value_type: "string"}
      [{_, messages}] = Lint.lint([entry])

      assert messages === [
               %Message{
                 replacement: %Replacement{value: "Éar", label: "Éar"},
                 check: :first_letter_case,
                 text: "éar"
               }
             ]
    end

    test "lint first letter lowercase entry" do
      entry = %Entry{key: "a", is_master: false, value: "Bar", master_value: "foo", value_type: "string"}
      [{_, messages}] = Lint.lint([entry])

      assert messages === [
               %Message{
                 replacement: %Replacement{value: "bar", label: "bar"},
                 check: :first_letter_case,
                 text: "Bar"
               }
             ]
    end
  end
end
