defmodule LangueTest.Formatter.Gettext.Header do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Langue.Formatter.Gettext

  alias LangueTest.Formatter.Gettext.Expectation.{
    Simple,
    LanguageHeader
  }

  test "language in header" do
    {_, result_serialize} = Accent.FormatterTestHelper.test_serialize(Simple, Gettext, "en")

    assert result_serialize =~ "Language: en"
  end

  test "language in header when previously empty" do
    {_, result_serialize} = Accent.FormatterTestHelper.test_serialize(LanguageHeader, Gettext, "en")

    assert result_serialize =~ "Language: en"
  end
end
