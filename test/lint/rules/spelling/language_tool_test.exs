defmodule AccentTest.Lint.Spelling.LanguageTool do
  use Accent.RepoCase, async: false

  import Mock

  alias Accent.Lint.Message
  alias Accent.Lint.Rules.Spelling.LanguageTool

  test "empty matches" do
    body = Jason.encode!(%{matches: []})
    response = [post: fn _url, _, _ -> {:ok, %{body: body}} end]

    with_mock HTTPoison, response do
      messges = LanguageTool.check("foo", "fr")

      assert messges === []
      assert called(HTTPoison.post("http://language-tool.test/v2/check", "text=foo&language=fr", [{"Content-Type", "application/x-www-form-urlencoded"}]))
    end
  end

  test "convert unsupported language" do
    body = Jason.encode!(%{matches: []})
    response = [post: fn _url, _, _ -> {:ok, %{body: body}} end]

    with_mock HTTPoison, response do
      messges = LanguageTool.check("foo", "blablabla")

      assert messges === []
      assert called(HTTPoison.post("http://language-tool.test/v2/check", "text=foo&language=auto", [{"Content-Type", "application/x-www-form-urlencoded"}]))
    end
  end

  test "map matches" do
    body =
      Jason.encode!(%{
        matches: [
          %{
            "message" => "Possible spelling mistake found",
            "shortMessage" => "Spelling mistake",
            "replacements" => [
              %{
                "value" => "hello"
              },
              %{
                "value" => "hell lo"
              }
            ],
            "offset" => 0,
            "length" => 6,
            "context" => %{
              "text" => "helllo",
              "offset" => 0,
              "length" => 6
            },
            "sentence" => "helllo",
            "type" => %{
              "typeName" => "Other"
            },
            "rule" => %{
              "id" => "MORFOLOGIK_RULE_EN_US",
              "description" => "Possible spelling mistake",
              "issueType" => "misspelling",
              "category" => %{
                "id" => "TYPOS",
                "name" => "Possible Typo"
              }
            },
            "ignoreForIncompleteSentence" => false,
            "contextForSureMatch" => 0
          }
        ]
      })

    response = [post: fn _url, _, _ -> {:ok, %{body: body}} end]

    with_mock HTTPoison, response do
      messges = LanguageTool.check("foo", "blablabla")

      assert messges === [
               %Message{
                 context: %Message.Context{
                   length: 6,
                   offset: 0,
                   text: "helllo"
                 },
                 fixed_text: "hello",
                 padded_text: "helllo",
                 replacements: [
                   %Message.Replacement{value: "hello"},
                   %Message.Replacement{value: "hell lo"}
                 ],
                 rule: %Message.Rule{
                   description: "Possible spelling mistake",
                   id: "MORFOLOGIK_RULE_EN_US"
                 },
                 text: "helllo"
               }
             ]

      assert called(HTTPoison.post("http://language-tool.test/v2/check", "text=foo&language=auto", [{"Content-Type", "application/x-www-form-urlencoded"}]))
    end
  end
end
