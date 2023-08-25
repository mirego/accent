defmodule AccentTest.GraphQL.Resolvers.Comment do
  @moduledoc false
  use Accent.RepoCase
  use Oban.Testing, repo: Accent.Repo

  alias Accent.Comment
  alias Accent.GraphQL.Resolvers.Comment, as: Resolver
  alias Accent.Language
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User

  defmodule PlugConn do
    @moduledoc false
    defstruct [:assigns]
  end

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    french_language = Repo.insert!(%Language{name: "french"})
    project = Repo.insert!(%Project{main_color: "#f00", name: "My project"})

    revision = Repo.insert!(%Revision{language_id: french_language.id, project_id: project.id, master: true})

    translation =
      Repo.insert!(%Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar"})

    {:ok, [user: user, project: project, translation: translation]}
  end

  test "create", %{translation: translation, project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.create(translation, %{text: "First comment"}, context)

    assert_enqueued(
      worker: Accent.Hook.Outbounds.Mock,
      args: %{
        "event" => "create_comment",
        "payload" => %{
          "text" => "First comment",
          "user" => %{"email" => user.email},
          "translation" => %{"id" => translation.id, "key" => translation.key}
        },
        "project_id" => project.id,
        "user_id" => user.id
      }
    )

    assert get_in(result, [:errors]) == nil
    assert get_in(Repo.all(Comment), [Access.all(), Access.key(:text)]) == ["First comment"]
  end

  test "delete", %{translation: translation, user: user} do
    comment = Repo.insert!(%Comment{translation_id: translation.id, text: "test", user: user})

    assert get_in(Repo.all(Comment), [Access.all(), Access.key(:id)]) == [comment.id]

    {:ok, result} = Resolver.delete(comment, nil, nil)

    assert get_in(result, [:errors]) == nil
    assert Repo.all(Comment) == []
  end

  test "update", %{translation: translation, user: user} do
    comment = Repo.insert!(%Comment{translation_id: translation.id, text: "test", user: user})

    assert get_in(Repo.all(Comment), [Access.all(), Access.key(:id)]) == [comment.id]

    {:ok, result} = Resolver.update(comment, %{text: "updated"}, nil)

    assert get_in(result, [:errors]) == nil
    assert get_in(Repo.all(Comment), [Access.all(), Access.key(:text)]) == ["updated"]
  end

  test "list project", %{project: project, translation: translation, user: user} do
    comment = Repo.insert!(%Comment{translation_id: translation.id, text: "test", user: user})

    {:ok, result} = Resolver.list_project(project, %{}, %{})

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [comment.id]
  end

  test "list translation", %{translation: translation, user: user} do
    comment = Repo.insert!(%Comment{translation_id: translation.id, text: "test", user: user})

    {:ok, result} = Resolver.list_translation(translation, %{}, %{})

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [comment.id]
  end
end
