defmodule AccentTest.Formatter.Es6Module.Formatter do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias AccentTest.Formatter.Es6Module.Expectation.{Simple, Plural}
  alias Langue.Formatter.Es6Module.{Parser, Serializer}

  @tests [
    Simple,
    Plural
  ]

  test "es6 module" do
    Enum.each(@tests, fn ex ->
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(ex, Parser)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(ex, Serializer)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end)
  end
end
