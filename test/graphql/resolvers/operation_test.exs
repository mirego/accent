defmodule AccentTest.GraphQL.Resolvers.Operation do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.GraphQL.Resolvers.Operation, as: Resolver
  alias Accent.Language
  alias Accent.Operation
  alias Accent.PreviousTranslation
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User

  setup do
    user = Factory.insert(User)
    french_language = Factory.insert(Language)
    project = Factory.insert(Project)

    revision = Factory.insert(Revision, language_id: french_language.id, project_id: project.id, master: true)
    context = %{context: %{conn: %Plug.Conn{assigns: %{current_user: user}}}}

    {:ok, [user: user, project: project, revision: revision, context: context]}
  end

  test "rollback", %{revision: revision, context: context} do
    translation =
      Factory.insert(Translation,
        revision_id: revision.id,
        conflicted: true,
        key: "ok",
        corrected_text: "baz",
        proposed_text: "bar"
      )

    previous_translation = %PreviousTranslation{
      conflicted: false,
      corrected_text: "bar",
      proposed_text: "bar",
      value_type: "string"
    }

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
