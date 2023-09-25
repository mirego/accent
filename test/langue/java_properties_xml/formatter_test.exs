defmodule LangueTest.Formatter.JavaPropertiesXml do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Langue.Formatter.JavaPropertiesXml

  Code.require_file("expectation_test.exs", __DIR__)

  @tests [
    Simple,
    PlaceholderValues
  ]

  for test <- @tests, module = Module.concat(LangueTest.Formatter.JavaPropertiesXml.Expectation, test) do
    test "java properties xml #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), JavaPropertiesXml)

      {expected_serialize, result_serialize} =
        Accent.FormatterTestHelper.test_serialize(unquote(module), JavaPropertiesXml)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
