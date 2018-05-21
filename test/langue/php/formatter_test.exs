defmodule LangueTest.Formatter.Php do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Langue.Formatter.Php

  @tests [
    ParsesDoubleQuotations
  ]

  for test <- @tests, module = Module.concat(LangueTest.Formatter.Php.Expectation, test) do
    test "Php #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), Php)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), Php)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
