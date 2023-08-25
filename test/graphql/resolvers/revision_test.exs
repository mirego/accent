defmodule AccentTest.GraphQL.Resolvers.Revision do
  @moduledoc false
  use Accent.RepoCase

  alias Accent.GraphQL.Resolvers.Revision, as: Resolver
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
    english_language = Repo.insert!(%Language{name: "english"})
    project = Repo.insert!(%Project{main_color: "#f00", name: "My project"})

    master_revision = Repo.insert!(%Revision{language_id: french_language.id, project_id: project.id, master: true})

    slave_revision =
      Repo.insert!(%Revision{
        language_id: english_language.id,
        project_id: project.id,
        master: false,
        master_revision_id: master_revision.id
      })

    {:ok, [user: user, project: project, master_revision: master_revision, slave_revision: slave_revision]}
  end

  test "delete", %{slave_revision: revision} do
    {:ok, result} = Resolver.delete(revision, %{}, %{})

    assert get_in(result, [:errors]) == nil
  end

  test "promote master", %{slave_revision: revision} do
    {:ok, result} = Resolver.promote_master(revision, %{}, %{})

    assert get_in(result, [:revision, Access.key(:master)]) == true
  end

  test "create", %{project: project, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}
    language = Repo.insert!(%Language{name: "spanish"})

    {:ok, result} = Resolver.create(project, %{language_id: language.id}, context)

    assert get_in(result, [:revision, Access.key(:language_id)]) == language.id
    assert get_in(result, [:errors]) == nil
  end

  test "update", %{slave_revision: revision} do
    {:ok, result} = Resolver.update(revision, %{name: "foo", slug: "bar"}, %{})

    assert get_in(result, [:revision, Access.key(:name)]) == "foo"
    assert get_in(result, [:revision, Access.key(:slug)]) == "bar"
  end

  test "update with null values", %{slave_revision: revision} do
    {:ok, result} = Resolver.update(revision, %{name: nil, slug: nil}, %{})

    assert get_in(result, [:revision, Access.key(:name)]) == nil
    assert get_in(result, [:revision, Access.key(:slug)]) == nil
  end

  test "correct all", %{master_revision: revision, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    Repo.insert!(%Translation{
      revision_id: revision.id,
      key: "ok",
      corrected_text: "bar",
      proposed_text: "bar",
      conflicted: true
    })

    {:ok, result} = Resolver.correct_all(revision, %{}, context)

    assert get_in(result, [:revision, Access.key(:translations_count)]) == 1
    assert get_in(result, [:revision, Access.key(:conflicts_count)]) == 0
    assert get_in(result, [:revision, Access.key(:reviewed_count)]) == 1
  end

  test "uncorrect all", %{master_revision: revision, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    Repo.insert!(%Translation{
      revision_id: revision.id,
      key: "ok",
      corrected_text: "bar",
      proposed_text: "bar",
      conflicted: false
    })

    {:ok, result} = Resolver.uncorrect_all(revision, %{}, context)

    assert get_in(result, [:revision, Access.key(:translations_count)]) == 1
    assert get_in(result, [:revision, Access.key(:conflicts_count)]) == 1
    assert get_in(result, [:revision, Access.key(:reviewed_count)]) == 0
  end

  test "show project", %{master_revision: revision, project: project} do
    {:ok, result} = Resolver.show_project(project, %{id: revision.id}, %{})

    assert get_in(result, [Access.key(:id)]) == revision.id
    assert get_in(result, [Access.key(:translations_count)]) == 0
    assert get_in(result, [Access.key(:conflicts_count)]) == 0
    assert get_in(result, [Access.key(:reviewed_count)]) == 0
  end

  test "list project", %{master_revision: master_revision, slave_revision: slave_revision, project: project} do
    {:ok, result} = Resolver.list_project(project, %{}, %{})

    assert get_in(result, [Access.all(), Access.key(:id)]) == [master_revision.id, slave_revision.id]
    assert get_in(result, [Access.all(), Access.key(:translations_count)]) == [0, 0]
    assert get_in(result, [Access.all(), Access.key(:conflicts_count)]) == [0, 0]
    assert get_in(result, [Access.all(), Access.key(:reviewed_count)]) == [0, 0]
  end
end
