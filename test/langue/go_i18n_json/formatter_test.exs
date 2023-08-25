defmodule LangueTest.Formatter.GoI18nJson do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Langue.Formatter.GoI18nJson

  Code.require_file("expectation_test.exs", __DIR__)

  @tests [
    Simple,
    UTF8
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
