if Langue.Formatter.Rails.enabled?() do
  defmodule LangueTest.Formatter.Rails do
    @moduledoc false
    use ExUnit.Case, async: true

    alias Langue.Formatter.Rails

    Code.require_file("expectation_test.exs", __DIR__)

    @tests [
      EmptyValue,
      NestedValues,
      ArrayValues,
      PluralValues,
      IntegerValues,
      PlaceholderValues,
      UnicodeValues
    ]

    for test <- @tests, module = Module.concat(LangueTest.Formatter.Rails.Expectation, test) do
      test "rails #{test}" do
        {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), Rails)
        {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), Rails)

        assert expected_parse == result_parse
        assert expected_serialize == result_serialize
      end
    end
  end
end
