defmodule LangueTest.Formatter.XLIFF12.ParseOnly do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Langue.Formatter.XLIFF12
  alias LangueTest.Formatter.XLIFF12.Expectation.HeaderAndBody
  alias LangueTest.Formatter.XLIFF12.Expectation.ReorderedSourceTarget
  alias LangueTest.Formatter.XLIFF12.Expectation.SymfonyFormat
  alias LangueTest.Formatter.XLIFF12.Expectation.TransUnitWithNotes

  Code.require_file("expectation_test.exs", __DIR__)

  @tests [
    SymfonyFormat,
    HeaderAndBody,
    TransUnitWithNotes,
    ReorderedSourceTarget
  ]

  for test <- @tests do
    test "xliff 1.2 parse #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(test), XLIFF12)

      assert expected_parse == result_parse
    end
  end
end
