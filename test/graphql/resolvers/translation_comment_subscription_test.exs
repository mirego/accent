defmodule AccentTest.GraphQL.Resolvers.TranslationCommentSubscription do
  use Accent.RepoCase

  import Mox
  setup :verify_on_exit!

  alias Accent.GraphQL.Resolvers.TranslationCommentSubscription, as: Resolver

  alias Accent.{
    Language,
    Project,
    Repo,
    Revision,
    Translation,
    TranslationCommentsSubscription,
    User
  }

  defmodule PlugConn do
    defstruct [:assigns]
  end

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    french_language = %Language{name: "french"} |> Repo.insert!()
    project = %Project{main_color: "#f00", name: "My project"} |> Repo.insert!()

    revision = %Revision{language_id: french_language.id, project_id: project.id, master: true} |> Repo.insert!()

    {:ok, [user: user, project: project, revision: revision]}
  end

  test "create", %{user: user, revision: revision} do
    translation = %Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar"} |> Repo.insert!()
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.create(translation, %{user_id: user.id}, context)

    assert get_in(result, [:errors]) == nil
    assert get_in(Repo.all(TranslationCommentsSubscription), [Access.all(), Access.key(:user_id)]) == [user.id]
  end

  test "delete", %{user: user, revision: revision} do
    translation = %Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar"} |> Repo.insert!()
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}
    subscription = %TranslationCommentsSubscription{user_id: user.id, translation_id: translation.id} |> Repo.insert!()

    {:ok, result} = Resolver.delete(subscription, %{}, context)

    assert get_in(result, [:errors]) == nil
    assert Repo.all(TranslationCommentsSubscription) == []
  end
end
