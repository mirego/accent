defmodule LangueTest.Formatter.SimpleJson do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Accent.FormatterTestHelper
  alias Langue.Formatter.SimpleJson
  alias LangueTest.Formatter.SimpleJson.Expectation.{SimpleParse, SimpleSerialize}

  @tests [
    Empty
  ]

  test "simple json parse" do
    {expected, result} = FormatterTestHelper.test_parse(SimpleParse, SimpleJson)
    assert expected == result
  end

  test "simple json serialize" do
    {expected, result} = FormatterTestHelper.test_serialize(SimpleSerialize, SimpleJson)
    assert expected == result
  end

  for test <- @tests, module = Module.concat(LangueTest.Formatter.SimpleJson.Expectation, test) do
    test "simple json #{test}" do
      {expected_parse, result_parse} = FormatterTestHelper.test_parse(unquote(module), SimpleJson)
      {expected_serialize, result_serialize} = FormatterTestHelper.test_serialize(unquote(module), SimpleJson)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
