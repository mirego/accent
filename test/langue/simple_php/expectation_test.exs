defmodule LangueTest.Formatter.SimplePhp.Expectation do
  @moduledoc false
  alias Langue.Entry

  defmodule NotNested do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      <?php

      return [
        'a'=>'Test',
        'b.c'=>'Not nested'
        ];
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "a", value: "Test", value_type: "string"},
        %Entry{index: 2, key: "b.c", value: "Not nested", value_type: "string"}
      ]
    end
  end
end
