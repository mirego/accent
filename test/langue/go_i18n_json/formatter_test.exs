defmodule LangueTest.Formatter.GoI18nJson do
  Code.require_file("expectation_test.exs", __DIR__)

  use ExUnit.Case, async: true

  alias Langue.Formatter.GoI18nJson

  @tests [
    Simple
  ]

  for test <- @tests, module = Module.concat(LangueTest.Formatter.GoI18nJson.Expectation, test) do
    test "go i18n json #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), GoI18nJson)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), GoI18nJson)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
