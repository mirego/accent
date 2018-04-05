defmodule AccentTest.Formatter.JavaProperties.Formatter do
  Code.require_file("expectation_test.exs", __DIR__)

  use ExUnit.Case, async: true

  alias AccentTest.Formatter.JavaProperties.Expectation.{Simple}
  alias Langue.Formatter.JavaProperties.{Parser, Serializer}

  @tests [
    Simple
  ]

  test "java properties" do
    Enum.each(@tests, fn ex ->
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(ex, Parser)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(ex, Serializer)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end)
  end
end
