defmodule AccentTest.Lint do
  use ExUnit.Case, async: true

  alias Accent.Lint
  alias Accent.Lint.Message
  alias Accent.Lint.Rules.Spelling.GatewayMock
  alias Langue.Entry

  import Mox
  setup :verify_on_exit!

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
               replacements: [%Message.Replacement{value: "foo"}],
               rule: %Message.Rule{
                 description: "Value contains trailing space",
                 id: "TRAILING_SPACES"
               },
               text: "foo "
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
    entry = %Entry{value: "foo", master_value: "foo %{bar}"}
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
    entry = %Entry{value: "foo", master_value: "foo https://google.ca"}
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
