defmodule LangueTest.Formatter.ARB do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Langue.Formatter.ARB

  @tests [
    Simple,
    Harder,
    NoMeta
  ]

  for test <- @tests, module = Module.concat(LangueTest.Formatter.ARB.Expectation, test) do
    test "arb #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), ARB)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), ARB)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
