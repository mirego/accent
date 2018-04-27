defmodule AccentTest.Formatter.Rails.Formatter do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias AccentTest.Formatter.Rails.Expectation.{EmptyValue, NestedValues, ArrayValues, IntegerValues, PluralValues}
  alias Langue.Formatter.Rails.{Parser, Serializer}

  @tests [
    EmptyValue,
    NestedValues,
    ArrayValues,
    PluralValues,
    IntegerValues
  ]

  test "rails_yaml" do
    Enum.each(@tests, fn ex ->
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(ex, Parser)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(ex, Serializer)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end)
  end
end
