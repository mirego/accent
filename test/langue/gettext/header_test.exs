defmodule LangueTest.Formatter.Gettext.Header do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Accent.FormatterTestHelper
  alias Langue.Formatter.Gettext
  alias LangueTest.Formatter.Gettext.Expectation.LanguageHeader
  alias LangueTest.Formatter.Gettext.Expectation.PluralFormsHeader
  alias LangueTest.Formatter.Gettext.Expectation.Simple

  Code.require_file("expectation_test.exs", __DIR__)

  test "language in header" do
    {_, result_serialize} = FormatterTestHelper.test_serialize(Simple, Gettext, %Accent.Language{slug: "en"})

    assert result_serialize =~ "Language: en"
  end

  test "plural forms in header" do
    plural_forms =
      "nplurals=3; plural=(n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2);"

    {_, result_serialize} =
      FormatterTestHelper.test_serialize(PluralFormsHeader, Gettext, %Accent.Language{
        slug: "en",
        plural_forms: plural_forms
      })

    assert result_serialize =~ "Plural-Forms: #{plural_forms}"
  end

  test "language in header when previously empty" do
    {_, result_serialize} = FormatterTestHelper.test_serialize(LanguageHeader, Gettext, %Accent.Language{slug: "en"})

    assert result_serialize =~ "Language: en"
  end
end
