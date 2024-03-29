defmodule LangueTest.Formatter.Es6Module do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Langue.Formatter.Es6Module

  Code.require_file("expectation_test.exs", __DIR__)

  @tests [
    Simple,
    Plural,
    PlaceholderValues
  ]

  for test <- @tests, module = Module.concat(LangueTest.Formatter.Es6Module.Expectation, test) do
    test "es6module #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), Es6Module)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), Es6Module)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
