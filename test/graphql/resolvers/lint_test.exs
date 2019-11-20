defmodule AccentTest.GraphQL.Resolvers.Lint do
  use Accent.RepoCase

  import Mox
  setup :verify_on_exit!

  alias Accent.{
    Language,
    Lint.Message,
    Project,
    Repo,
    Revision,
    Translation,
    User
  }

  alias Accent.GraphQL.Resolvers.Lint, as: Resolver
  alias Accent.Lint.Rules.Spelling.GatewayMock

  defmodule PlugConn do
    defstruct [:assigns]
  end

  @user %User{email: "test@test.com"}

  setup do
    expect(GatewayMock, :check, fn _, _ -> [] end)

    user = Repo.insert!(@user)
    french_language = %Language{name: "french"} |> Repo.insert!()
    project = %Project{main_color: "#f00", name: "My project"} |> Repo.insert!()

    revision = %Revision{language_id: french_language.id, project_id: project.id, master: true} |> Repo.insert!()
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, [user: user, project: project, revision: revision, context: context]}
  end

  test "lint", %{revision: revision, context: context} do
    translation = %Translation{revision_id: revision.id, conflicted: false, key: "ok", corrected_text: "bar  foo", proposed_text: "bar"} |> Repo.insert!()

    {:ok, result} = Resolver.lint_translation(translation, %{}, context)

    assert result === [
             %Message{
               replacements: [
                 %Message.Replacement{value: "bar foo"}
               ],
               rule: %Message.Rule{
                 description: "Value contains double spaces",
                 id: "DOUBLE_SPACES"
               },
               text: "bar  foo"
             }
           ]
  end
end
