defmodule AccentTest.GraphQL.Resolvers.Comment do
  use Accent.RepoCase

  import Mox
  setup :verify_on_exit!

  alias Accent.GraphQL.Resolvers.Comment, as: Resolver

  alias Accent.{
    Comment,
    Language,
    Project,
    Repo,
    Revision,
    Translation,
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
    translation = %Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar"} |> Repo.insert!()

    {:ok, [user: user, project: project, translation: translation]}
  end

  test "create", %{translation: translation, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    Accent.Hook.BroadcasterMock
    |> expect(:notify, fn _ -> :ok end)

    {:ok, result} = Resolver.create(translation, %{text: "First comment"}, context)

    assert get_in(result, [:errors]) == nil
    assert get_in(Repo.all(Comment), [Access.all(), Access.key(:text)]) == ["First comment"]
  end

  test "list project", %{project: project, translation: translation, user: user} do
    comment = %Comment{translation_id: translation.id, text: "test", user: user} |> Repo.insert!()

    {:ok, result} = Resolver.list_project(project, %{}, %{})

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [comment.id]
  end

  test "list translation", %{translation: translation, user: user} do
    comment = %Comment{translation_id: translation.id, text: "test", user: user} |> Repo.insert!()

    {:ok, result} = Resolver.list_translation(translation, %{}, %{})

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [comment.id]
  end
end
