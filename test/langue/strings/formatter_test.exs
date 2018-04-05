defmodule AccentTest.Formatter.Strings.Formatter do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias AccentTest.Formatter.Strings.Expectation.{Simple, Commented, Multiline, EmptyValue}
  alias Langue.Formatter.Strings.{Parser, Serializer}

  @tests [
    Simple,
    EmptyValue,
    Commented,
    Multiline
  ]

  test "strings" do
    Enum.each(@tests, fn ex ->
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(ex, Parser)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(ex, Serializer)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end)
  end
end
