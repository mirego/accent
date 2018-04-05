defmodule AccentTest.Formatter.Es6Module.Formatter do
  use ExUnit.Case, async: true

  Code.require_file("expectation_test.exs", __DIR__)

  alias AccentTest.Formatter.Es6Module.Expectation.{Simple}
  alias Langue.Formatter.Es6Module.{Parser, Serializer}

  @tests [
    {:test_parse, Simple, Parser},
    {:test_serialize, Simple, Serializer}
  ]

  test "es6 module" do
    Enum.each(@tests, fn {fun, ex, mo} ->
      {expected, result} = apply(Accent.FormatterTestHelper, fun, [ex, mo])
      assert expected == result
    end)
  end
end
