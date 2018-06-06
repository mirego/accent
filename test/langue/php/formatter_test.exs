defmodule LangueTest.Formatter.LaravelPhp do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Langue.Formatter.LaravelPhp

  @tests [
    ParsesDoubleQuotations
  ]

  for test <- @tests, module = Module.concat(LangueTest.Formatter.LaravelPhp.Expectation, test) do
    test "Laravel Php #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), Php)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), Php)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
