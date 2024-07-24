defmodule AccentTest.GraphQL.Resolvers.TranslationCommentSubscription do
  @moduledoc false
  use Accent.RepoCase, async: true

  import Mox

  alias Accent.GraphQL.Resolvers.TranslationCommentSubscription, as: Resolver
  alias Accent.Language
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.TranslationCommentsSubscription
  alias Accent.User

  setup :verify_on_exit!

  defmodule PlugConn do
    @moduledoc false
    defstruct [:assigns]
  end

  setup do
    user = Factory.insert(User)
    french_language = Factory.insert(Language)
    project = Factory.insert(Project)

    revision = Factory.insert(Revision, language_id: french_language.id, project_id: project.id, master: true)

    {:ok, [user: user, project: project, revision: revision]}
  end

  test "create", %{user: user, revision: revision} do
    translation =
      Factory.insert(Translation, revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar")

    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.create(translation, %{user_id: user.id}, context)

    assert get_in(result, [:errors]) == nil
    assert get_in(Repo.all(TranslationCommentsSubscription), [Access.all(), Access.key(:user_id)]) == [user.id]
  end

  test "delete", %{user: user, revision: revision} do
    translation =
      Factory.insert(Translation, revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar")

    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}
    subscription = Factory.insert(TranslationCommentsSubscription, user_id: user.id, translation_id: translation.id)

    {:ok, result} = Resolver.delete(subscription, %{}, context)

    assert get_in(result, [:errors]) == nil
    assert Repo.all(TranslationCommentsSubscription) == []
  end
end
