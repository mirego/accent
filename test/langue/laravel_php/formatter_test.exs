defmodule LangueTest.Formatter.LaravelPhp do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Langue.Formatter.LaravelPhp

  Code.require_file("expectation_test.exs", __DIR__)

  @tests [
    ParsesDoubleQuotations
  ]

  for test <- @tests, module = Module.concat(LangueTest.Formatter.LaravelPhp.Expectation, test) do
    test "Laravel Php #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), LaravelPhp)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), LaravelPhp)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
