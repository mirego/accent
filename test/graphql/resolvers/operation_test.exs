defmodule AccentTest.GraphQL.Resolvers.Operation do
  use Accent.RepoCase

  alias Accent.GraphQL.Resolvers.Operation, as: Resolver

  alias Accent.{
    Language,
    Operation,
    PreviousTranslation,
    Project,
    Repo,
    Revision,
    Translation,
    User
  }

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    french_language = %Language{name: "french"} |> Repo.insert!()
    project = %Project{main_color: "#f00", name: "My project"} |> Repo.insert!()

    revision = %Revision{language_id: french_language.id, project_id: project.id, master: true} |> Repo.insert!()
    context = %{context: %{conn: %Plug.Conn{assigns: %{current_user: user}}}}

    {:ok, [user: user, project: project, revision: revision, context: context]}
  end

  test "rollback", %{revision: revision, context: context} do
    translation = %Translation{revision_id: revision.id, conflicted: true, key: "ok", corrected_text: "baz", proposed_text: "bar"} |> Repo.insert!()
    previous_translation = %PreviousTranslation{conflicted: false, corrected_text: "bar", proposed_text: "bar", value_type: "string"}

    operation =
      %Operation{
        previous_translation: previous_translation,
        translation_id: translation.id,
        revision_id: revision.id,
        key: "ok",
        text: "baz",
        value_type: "string",
        action: "update"
      }
      |> Repo.insert!()
      |> Repo.preload(:translation)

    {:ok, result} = Resolver.rollback(operation, %{}, context)

    assert get_in(result, [:errors]) == nil
    assert get_in(result, [:operation]) == true
    assert Repo.get(Operation, operation.id).rollbacked == true
    assert get_in(Repo.all(Translation), [Access.all(), Access.key(:corrected_text)]) == ["bar"]
    assert get_in(Repo.all(Translation), [Access.all(), Access.key(:conflicted)]) == [false]
  end
end
