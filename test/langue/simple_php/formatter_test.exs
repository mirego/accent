defmodule LangueTest.Formatter.SimplePhp do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Langue.Formatter.SimplePhp

  Code.require_file("expectation_test.exs", __DIR__)

  @tests [
    NotNested
  ]

  for test <- @tests, module = Module.concat(LangueTest.Formatter.SimplePhp.Expectation, test) do
    test "Laravel Php #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), SimplePhp)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), SimplePhp)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
