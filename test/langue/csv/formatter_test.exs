defmodule Langue.Formatter.CSVTest do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Langue.Formatter.CSV

  @tests [
    Simple
  ]

  for test <- @tests, module = Module.concat(Langue.Formatter.CSV.ExpectationTest, test) do
    test "csv #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), CSV)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), CSV)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
