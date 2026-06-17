defmodule LangueTest.Formatter.RailsYml do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Langue.Formatter.RailsYml

  Code.require_file("expectation_test.exs", __DIR__)

  @tests [Empty, Simple, Nested, Array, Types, PlaceholderValues]

  for test <- @tests, module = Module.concat(LangueTest.Formatter.RailsYml.Expectation, test) do
    test "rails_yml #{test}" do
      {expected_parse, result_parse} = Accent.FormatterTestHelper.test_parse(unquote(module), RailsYml)
      {expected_serialize, result_serialize} = Accent.FormatterTestHelper.test_serialize(unquote(module), RailsYml)

      assert expected_parse == result_parse
      assert expected_serialize == result_serialize
    end
  end
end
