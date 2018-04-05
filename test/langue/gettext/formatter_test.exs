defmodule AccentTest.Formatter.Gettext.Parser do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Accent.FormatterTestHelper
  alias AccentTest.Formatter.Gettext.Expectation.{DotKeys, Pluralization, Simple}
  alias Langue.Formatter.Gettext.{Parser, Serializer}

  @tests [
    DotKeys,
    Pluralization,
    Simple
  ]

  test "gettext" do
    Enum.each(@tests, fn ex ->
      {expected_parse, result_parse} = FormatterTestHelper.test_parse(ex, Parser)
      {expected_serialize, result_serialize} = FormatterTestHelper.test_serialize(ex, Serializer)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end)
  end

  test "language in header" do
    {_, result_serialize} = FormatterTestHelper.test_serialize(Simple, Serializer, "en")

    assert result_serialize =~ "Language: en"
  end
end
