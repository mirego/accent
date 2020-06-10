defmodule AccentTest.Lint do
  use ExUnit.Case, async: true

  alias Accent.Lint
  alias Accent.Lint.Message
  alias Accent.Lint.Replacement
  alias Langue.Entry

  describe "lint/2" do
    test "lint valid entry" do
      entry = %Entry{value: "foo", master_value: "foo"}
      [linted] = Lint.lint([entry])

      assert linted.messages === []
    end

    test "lint trailing space entry" do
      entry = %Entry{value: "foo ", master_value: "foo"}
      [linted] = Lint.lint([entry])

      assert linted.messages === [
               %Message{
                 replacement: %Replacement{value: "foo", label: "foo"},
                 check: :trailing_space,
                 text: "foo "
               }
             ]
    end

    test "lint double spaces entry" do
      entry = %Entry{value: "fo  o", master_value: "foo"}
      [linted] = Lint.lint([entry])

      assert linted.messages === [
               %Message{
                 replacement: %Replacement{value: "fo o", label: "fo o"},
                 check: :double_spaces,
                 text: "fo  o"
               }
             ]
    end
  end
end
