defmodule LangueTest.Formatter.Json.Exception do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Langue.Formatter.Json
  alias LangueTest.Formatter.Json.Expectation.{InvalidFloatValue, InvalidIntegerValue}

  test "invalid integer value" do
    {expected_parse, result_parse} = Accent.FormatterTestHelper.test_serialize(InvalidIntegerValue, Json)

    assert expected_parse == result_parse
  end

  test "invalid float value" do
    {expected_parse, result_parse} = Accent.FormatterTestHelper.test_serialize(InvalidFloatValue, Json)

    assert expected_parse == result_parse
  end
end
