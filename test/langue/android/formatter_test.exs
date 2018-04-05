defmodule AccentTest.Formatter.Android.Formatter do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias AccentTest.Formatter.Android.Expectation.{Simple, EmptyValue, UnsupportedTag, RuntimeError, Commented, Array, ValueEscaping}
  alias Langue.Formatter.Android.{Parser, Serializer}
  alias Accent.FormatterTestHelper

  @tests [
    Simple,
    EmptyValue,
    Commented,
    Array,
    ValueEscaping
  ]

  test "android XML" do
    Enum.each(@tests, fn ex ->
      {expected_parse, result_parse} = FormatterTestHelper.test_parse(ex, Parser)
      {expected_serialize, result_serialize} = FormatterTestHelper.test_serialize(ex, Serializer)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end)
  end

  test "android XML unsupported tag" do
    {expected_parse, result_parse} = FormatterTestHelper.test_parse(UnsupportedTag, Parser)

    assert expected_parse == result_parse
  end

  test "android XML with runtime error" do
    {_, result_parse} = FormatterTestHelper.test_parse(RuntimeError, Parser)

    assert result_parse == []
  end
end
