defmodule LangueTest.Formatter.Android.Exception do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Langue.Formatter.Android
  alias LangueTest.Formatter.Android.Expectation.{RuntimeError, UnsupportedTag}

  test "android XML unsupported tag" do
    {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(UnsupportedTag, Android)

    assert expected_parse == result_parse
  end

  test "android XML with runtime error" do
    {_, result_parse} = Accent.FormatterTestHelper.test_parse(RuntimeError, Android)

    assert result_parse == []
  end
end
