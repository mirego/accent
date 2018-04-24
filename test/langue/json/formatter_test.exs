defmodule AccentTest.Formatter.Json.Parser do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias AccentTest.Formatter.Json.Expectation.{Empty, NilValue, EmptyValue, BooleanValue, IntegerValue, FloatValue, Simple, Nested, Complexe}
  alias Langue.Formatter.Json.{Parser, Serializer}

  @tests [
    Empty,
    NilValue,
    EmptyValue,
    BooleanValue,
    IntegerValue,
    FloatValue,
    Simple,
    Nested,
    Complexe
  ]

  test "json" do
    Enum.each(@tests, fn ex ->
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(ex, Parser)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(ex, Serializer)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end)
  end
end
