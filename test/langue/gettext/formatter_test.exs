defmodule LangueTest.Formatter.Gettext do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias Langue.Formatter.Gettext

  @tests [
    Simple,
    DotKeys,
    Pluralization,
    PlaceholderValues,
    ContextValues
  ]

  for test <- @tests, module = Module.concat(LangueTest.Formatter.Gettext.Expectation, test) do
    test "gettext #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), Gettext)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), Gettext)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
