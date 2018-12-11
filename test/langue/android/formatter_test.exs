defmodule LangueTest.Formatter.Android do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Langue.Formatter.Android

  @tests [
    Simple,
    EmptyValue,
    Commented,
    Array,
    StringsFormatEscape,
    ValueEscaping,
    InterpolationValues
  ]

  for test <- @tests, module = Module.concat(LangueTest.Formatter.Android.Expectation, test) do
    test "android #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), Android)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), Android)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
