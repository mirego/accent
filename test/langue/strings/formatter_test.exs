defmodule LangueTest.Formatter.Strings do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Langue.Formatter.Strings

  @tests [
    Simple,
    EmptyValue,
    Commented,
    Multiline
  ]

  for test <- @tests, module = Module.concat(LangueTest.Formatter.Strings.Expectation, test) do
    test "strings #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), Strings)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), Strings)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
