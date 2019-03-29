defmodule LangueTest.Formatter.XLIFF12 do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Langue.Formatter.XLIFF12

  @tests [
    Simple
  ]

  for test <- @tests, module = Module.concat(LangueTest.Formatter.XLIFF12.Expectation, test) do
    test "xliff 1.2 #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), XLIFF12)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), XLIFF12)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
