defmodule LangueTest.Formatter.Json do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Langue.Formatter.Json

  @tests [
    Empty,
    NilValue,
    EmptyValue,
    BooleanValue,
    IntegerValue,
    FloatValue,
    Simple,
    Nested,
    Complexe,
    InterpolationValues
  ]

  for test <- @tests, module = Module.concat(LangueTest.Formatter.Json.Expectation, test) do
    test "json #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), Json)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), Json)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
