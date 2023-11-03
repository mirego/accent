defmodule LangueTest.Formatter.Gettext.Exception do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Langue.Entry
  alias Langue.Formatter.Gettext
  alias LangueTest.Formatter.Gettext.Expectation.EmptyComment

  Code.require_file("expectation_test.exs", __DIR__)

  test "empty string comment" do
    {expected_parse, result_parse} = Accent.FormatterTestHelper.test_serialize(EmptyComment, Gettext)

    assert expected_parse == result_parse
  end

  test "plurialization export sorting" do
    entries = [
      %Entry{
        index: 1,
        key: "should be at least n character(s).__KEY__0",
        value: "should be at least 0 characters",
        plural: true,
        value_type: "string"
      },
      %Entry{
        index: 2,
        key: "should be at least n character(s).__KEY__1",
        value: "should be at least %{count} character(s)",
        plural: true,
        value_type: "string",
        placeholders: ~w(%{count})
      },
      %Entry{
        index: 3,
        key: "should be at least n character(s).__KEY___",
        value: "should be at least %{count} character(s)",
        plural: true,
        locked: true,
        value_type: "plural",
        placeholders: ~w(%{count})
      }
    ]

    result =
      Gettext.serialize(%Langue.Formatter.ParserResult{
        entries: entries,
        language: %{slug: "foo", plural_forms: "none"},
        document: %{top_of_the_file_comment: "", header: header()}
      })

    assert result.render === """
           msgid ""
           msgstr ""
           "Language: foo"

           msgid "should be at least n character(s)"
           msgid_plural "should be at least %{count} character(s)"
           msgstr[0] "should be at least 0 characters"
           msgstr[1] "should be at least %{count} character(s)"
           """
  end

  def header do
    String.trim_trailing(~S"""
    "Language: fr"
    """)
  end
end
