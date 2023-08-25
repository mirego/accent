defmodule LangueTest.Formatter.JavaProperties do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Langue.Formatter.JavaProperties

  Code.require_file("expectation_test.exs", __DIR__)

  @tests [
    Simple,
    PlaceholderValues
  ]

  for test <- @tests, module = Module.concat(LangueTest.Formatter.JavaProperties.Expectation, test) do
    test "java properties #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), JavaProperties)

      {expected_serialize, result_serialize} =
        Accent.FormatterTestHelper.test_serialize(unquote(module), JavaProperties)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
