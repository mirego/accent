defmodule AccentTest.Lint do
  use ExUnit.Case, async: true

  alias Accent.Lint
  alias Accent.Lint.Message
  alias Accent.Lint.Rules.Spelling.GatewayMock
  alias Langue.Entry

  import Mox
  setup :verify_on_exit!

  describe "display_trailing_text/1" do
    test "short" do
      assert Lint.display_trailing_text("foo") === "foo"
    end

    test "on max length" do
      assert Lint.display_trailing_text("12345678912") === "12345678912"
    end

    test "longer than max length" do
      assert Lint.display_trailing_text("1234567891234") === "…234567891234"
    end

    test "much longer than max length" do
      assert Lint.display_trailing_text("123456789123456789") === "…789123456789"
    end
  end

  describe "lint/2" do
    setup do
      expect(GatewayMock, :check, fn _, _ -> [] end)

      :ok
    end

    test "lint valid entry" do
      entry = %Entry{value: "foo", master_value: "foo"}
      [linted] = Lint.lint([entry], language: "en")

      assert linted.messages === []
    end

    test "lint trailing space entry" do
      entry = %Entry{value: "foo ", master_value: "foo"}
      [linted] = Lint.lint([entry], language: "en")

      assert linted.messages === [
               %Message{
                 context: %Message.Context{length: 4, offset: 0, text: "foo "},
                 replacements: [%Message.Replacement{value: "foo"}],
                 rule: %Message.Rule{
                   description: "Value contains trailing space",
                   id: "TRAILING_SPACES"
                 },
                 text: "foo "
               }
             ]
    end

    test "lint trailing colon entry" do
      entry = %Entry{value: "foo", is_master: false, master_value: "foo:"}
      [linted] = Lint.lint([entry], language: "en")

      assert linted.messages === [
               %Message{
                 context: %Message.Context{length: 3, offset: 0, text: "foo"},
                 replacements: [%Message.Replacement{value: "foo:"}],
                 rule: %Message.Rule{description: "Translation does not match trailing colons of the source", id: "TRAILING_COLON"},
                 text: "foo:"
               }
             ]
    end

    test "lint trailing ellipsis entry" do
      entry = %Entry{value: "boo", is_master: false, master_value: "foo…"}
      [linted] = Lint.lint([entry], language: "en")

      assert linted.messages === [
               %Message{
                 context: %Message.Context{length: 3, offset: 0, text: "boo"},
                 replacements: [%Message.Replacement{value: "boo…"}],
                 rule: %Message.Rule{description: "Translation does not match ellipsis of the source", id: "TRAILING_ELLIPSIS"},
                 text: "foo…"
               }
             ]
    end

    test "lint trailing exclamation entry" do
      entry = %Entry{value: "boo", is_master: false, master_value: "foo!"}
      [linted] = Lint.lint([entry], language: "en")

      assert linted.messages === [
               %Message{
                 context: %Message.Context{length: 3, offset: 0, text: "boo"},
                 replacements: [%Message.Replacement{value: "boo!"}],
                 rule: %Message.Rule{description: "Translation does not match exclamation of the source", id: "TRAILING_EXCLAMATION"},
                 text: "foo!"
               }
             ]
    end

    test "lint trailing question mark entry" do
      entry = %Entry{value: "boo", is_master: false, master_value: "foo?"}
      [linted] = Lint.lint([entry], language: "en")

      assert linted.messages === [
               %Message{
                 context: %Message.Context{length: 3, offset: 0, text: "boo"},
                 replacements: [%Message.Replacement{value: "boo?"}],
                 rule: %Message.Rule{description: "Translation does not match question mark of the source", id: "TRAILING_QUESTION_MARK"},
                 text: "foo?"
               }
             ]
    end

    test "lint trailing stop entry" do
      entry = %Entry{value: "boo", is_master: false, master_value: "foo."}
      [linted] = Lint.lint([entry], language: "en")

      assert linted.messages === [
               %Message{
                 context: %Message.Context{length: 3, offset: 0, text: "boo"},
                 replacements: [%Message.Replacement{value: "boo."}],
                 rule: %Message.Rule{description: "Translation does not match full stop of the source", id: "TRAILING_STOP"},
                 text: "foo."
               }
             ]
    end

    test "lint three dots ellipsis entry" do
      entry = %Entry{value: "boo...", master_value: "boo..."}
      [linted] = Lint.lint([entry], language: "en")

      assert linted.messages === [
               %Message{
                 replacements: [%Message.Replacement{value: "boo…"}],
                 rule: %Message.Rule{description: "Value contains three dots instead of ellipsis", id: "THREE_DOTS_ELLIPSIS"},
                 text: "boo..."
               }
             ]
    end

    test "lint double spaces entry" do
      entry = %Entry{value: "boo  baa", master_value: "boo  baa"}
      [linted] = Lint.lint([entry], language: "en")

      assert linted.messages === [
               %Message{
                 replacements: [%Message.Replacement{value: "boo baa"}],
                 rule: %Message.Rule{description: "Value contains double spaces", id: "DOUBLE_SPACES"},
                 text: "boo  baa"
               }
             ]
    end

    test "lint leading space entry" do
      entry = %Entry{value: " foo", master_value: "foo"}
      [linted] = Lint.lint([entry], language: "en")

      assert linted.messages === [
               %Message{
                 replacements: [%Message.Replacement{value: "foo"}],
                 rule: %Message.Rule{
                   description: "Value contains leading space",
                   id: "LEADING_SPACES"
                 },
                 text: " foo"
               }
             ]
    end

    test "lint placeholder count entry" do
      entry = %Entry{value: "foo", is_master: false, master_value: "foo %{bar}"}
      [linted] = Lint.lint([entry], language: "en")

      assert linted.messages === [
               %Message{
                 rule: %Message.Rule{
                   description: "Value contains a different number of placeholders (0) from the master value (1)",
                   id: "PLACEHOLDER_COUNT"
                 },
                 text: "foo"
               }
             ]
    end

    test "lint url count entry" do
      entry = %Entry{value: "foo", is_master: false, master_value: "foo https://google.ca"}
      [linted] = Lint.lint([entry], language: "en")

      assert linted.messages === [
               %Message{
                 rule: %Message.Rule{
                   description: "Value contains a different number of URL (0) from the master value (1)",
                   id: "URL_COUNT"
                 },
                 text: "foo"
               }
             ]
    end
  end
end
