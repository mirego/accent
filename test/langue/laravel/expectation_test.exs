defmodule LangueTest.Formatter.Laravel.Expectation do
  alias Langue.Entry

  defmodule ParsesAnyQuotation do
    use Langue.Expectation.Case

    def render do
      """
      <?php

      return [
        "some_double_quoted_key" => "Some double quoted value",
        "another_double_quoted_key" => 'A single quoted value',
        'some_single_quoted_key' => "With a double quoted value",
        'another_single_quoted_key' => 'With a single quoted value'
      ];
      """
    end

    def entries do
      [
        %Entry{comment: "", index: 1, key: "some_double_quoted_key", value: "Some double quoted value" },
        %Entry{comment: "", index: 1, key: "another_double_quoted_key", value: "A single quoted value" },
        %Entry{comment: "", index: 1, key: "some_single_quoted_key", value: "With a double quoted value" },
        %Entry{comment: "", index: 1, key: "another_single_quoted_key", value: "With a single quoted value" },
      ]
    end
  end
end
