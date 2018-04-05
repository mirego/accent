defmodule AccentTest.Formatter.SimpleJson.Parser do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Accent.FormatterTestHelper
  alias AccentTest.Formatter.SimpleJson.Expectation.{Empty, SimpleParse, SimpleSerialize}
  alias Langue.Formatter.SimpleJson.{Parser, Serializer}

  @tests [
    Empty
  ]

  test "simple json parse" do
    {expected, result} = FormatterTestHelper.test_parse(SimpleParse, Parser)
    assert expected == result
  end

  test "simple json serialize" do
    {expected, result} = FormatterTestHelper.test_serialize(SimpleSerialize, Serializer)
    assert expected == result
  end

  test "simple json" do
    Enum.each(@tests, fn ex ->
      {expected_parse, result_parse} = FormatterTestHelper.test_parse(ex, Parser)
      {expected_serialize, result_serialize} = FormatterTestHelper.test_serialize(ex, Serializer)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end)
  end
end
