defmodule AccentTest.Formatter.Es6Module.Expectation do
  alias Langue.Entry

  defmodule Simple do
    use Langue.Expectation.Case

    def render do
      """
      export default {
        "general": {
          "nested": "value ok",
          "roles": {
            "owner": "Owner"
          }
        },
        "test": "OK"
      };
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "general.nested", value: "value ok", comment: ""},
        %Entry{index: 2, key: "general.roles.owner", value: "Owner", comment: ""},
        %Entry{index: 3, key: "test", value: "OK", comment: ""}
      ]
    end
  end
end
