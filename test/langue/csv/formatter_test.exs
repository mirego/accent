defmodule AccentTest.Formatter.Csv.Formatter do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Langue.Formatter.Csv.{Parser, Serializer}

  @tests [
    Simple
  ]

  for test <- @tests, module = Module.concat(Langue.Csv.ExpectationTest, test) do
    test "csv #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), Parser)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), Serializer)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
