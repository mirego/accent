defmodule LangueTest.Formatter.Laravel do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Langue.Formatter.Laravel

  @tests [
    ParsesDoubleQuotations
  ]

  for test <- @tests, module = Module.concat(LangueTest.Formatter.Laravel.Expectation, test) do
    test "json #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), Laravel)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), Laravel)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
