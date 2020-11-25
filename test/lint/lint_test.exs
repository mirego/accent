defmodule AccentTest.Lint do
  use ExUnit.Case, async: true

  alias Accent.Lint
  alias Accent.Lint.Message
  alias Accent.Lint.Replacement
  alias Langue.Entry

  describe "lint/2" do
    test "lint valid entry" do
      entry = %Entry{key: "a", value: "foo", master_value: "foo", value_type: "string"}
      [linted] = Lint.lint([entry])

      assert linted.messages === []
    end

    test "lint trailing space entry" do
      entry = %Entry{key: "a", value: "foo ", master_value: "foo", value_type: "string"}
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
      entry = %Entry{key: "a", value: "fo  o", master_value: "foo", value_type: "string"}
      [linted] = Lint.lint([entry])

      assert linted.messages === [
               %Message{
                 replacement: %Replacement{value: "fo o", label: "fo o"},
                 check: :double_spaces,
                 text: "fo  o"
               }
             ]
    end

    test "lint three dots ellipsis entry" do
      entry = %Entry{key: "a", value: "foo...", master_value: "foo...", value_type: "string"}
      [linted] = Lint.lint([entry])

      assert linted.messages === [
               %Message{
                 replacement: %Replacement{value: "foo…", label: "foo…"},
                 check: :three_dots_ellipsis,
                 text: "foo..."
               }
             ]
    end
  end
end
