defmodule AccentTest.Lint.Rules.Spelling do
  use ExUnit.Case, async: true

  alias Accent.Lint
  alias Accent.Lint.Message
  alias Accent.Lint.Rules.Spelling.GatewayMock
  alias Langue.Entry

  import Mox
  setup :verify_on_exit!

  test "lint valid entry" do
    entry = %Entry{value: "foo", master_value: "foo"}

    expect(GatewayMock, :check, fn "foo", "fr-CA" ->
      [
        %Message{
          replacements: [%Message.Replacement{value: "fou"}],
          rule: %Message.Rule{
            description: "Word is spelled wrong",
            id: "SPELLING_MISTAKE"
          },
          text: "foo "
        }
      ]
    end)

    [linted] = Lint.lint([entry], language: "fr-CA")

    assert linted.messages === [
             %Message{
               replacements: [%Message.Replacement{value: "fou"}],
               rule: %Message.Rule{
                 description: "Word is spelled wrong",
                 id: "SPELLING_MISTAKE"
               },
               text: "foo "
             }
           ]
  end
end
