defmodule LangueTest.Formatter.Gettext.Exception do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Langue.Formatter.Gettext
  alias LangueTest.Formatter.Gettext.Expectation.EmptyComment

  test "empty string comment" do
    {expected_parse, result_parse} = Accent.FormatterTestHelper.test_serialize(EmptyComment, Gettext)

    assert expected_parse == result_parse
  end
end
