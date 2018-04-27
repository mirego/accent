defmodule AccentTest.Formatter.Gettext.Parser do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Accent.FormatterTestHelper

  alias AccentTest.Formatter.Gettext.Expectation.{
    DotKeys,
    Pluralization,
    Simple,
    LanguageHeader
  }

  alias Langue.Formatter.Gettext.{Parser, Serializer}

  @tests [
    DotKeys,
    Pluralization,
    Simple
  ]

  for ex <- @tests do
    test "gettext #{ex}" do
      {expected_parse, result_parse} = FormatterTestHelper.test_parse(unquote(ex), Parser)
      {expected_serialize, result_serialize} = FormatterTestHelper.test_serialize(unquote(ex), Serializer)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end

  test "language in header" do
    {_, result_serialize} = FormatterTestHelper.test_serialize(Simple, Serializer, "en")

    assert result_serialize =~ "Language: en"
  end

  test "language in header when previously empty" do
    {_, result_serialize} = FormatterTestHelper.test_serialize(LanguageHeader, Serializer, "en")

    assert result_serialize =~ "Language: en"
  end
end
