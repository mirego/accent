defmodule AccentTest.GraphQL.Resolvers.Activity do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.GraphQL.Resolvers.Activity, as: Resolver
  alias Accent.Language
  alias Accent.Operation
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User

  doctest Accent.GraphQL.Resolvers.Activity, import: true

  defmodule PlugConn do
    @moduledoc false
    defstruct [:assigns]
  end

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "french"})
    project = Repo.insert!(%Project{main_color: "#f00", name: "My project"})

    revision = Repo.insert!(%Revision{language_id: language.id, project_id: project.id, master: true})

    translation =
      Repo.insert!(%Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar"})

    {:ok, [user: user, project: project, revision: revision, translation: translation]}
  end

  test "list activities", %{user: user, project: project, translation: translation, revision: revision} do
    operation = Repo.insert!(%Operation{user_id: user.id, project_id: project.id, action: "sync"})

    Repo.insert!(%Operation{
      user_id: user.id,
      translation_id: translation.id,
      revision_id: revision.id,
      key: translation.key,
      text: "foo",
      action: "update",
      batch_operation_id: operation.id
    })

    {:ok, %{entries: entries, meta: meta}} = Resolver.list_operations(operation, %{}, %{})

    assert Enum.count(entries) == 1
    assert meta.current_page == 1
    assert meta.total_pages == 1
    assert meta.total_entries == 1
    assert meta.next_page == nil
    assert meta.previous_page == nil
  end

  test "list project", %{user: user, project: project, translation: translation, revision: revision} do
    Repo.insert!(%Operation{
      user_id: user.id,
      translation_id: translation.id,
      revision_id: revision.id,
      key: translation.key,
      text: "foo",
      action: "update"
    })

    Repo.insert!(%Operation{user_id: user.id, project_id: project.id, action: "sync"})
    {:ok, %{entries: entries, meta: meta}} = Resolver.list_project(project, %{}, %{})

    assert Enum.count(entries) == 2
    assert meta.current_page == 1
    assert meta.total_pages == 1
    assert meta.total_entries == 2
    assert meta.next_page == nil
    assert meta.previous_page == nil
  end

  test "list project paginated", %{user: user, project: project} do
    for _index <- 1..100 do
      Repo.insert!(%Operation{user_id: user.id, project_id: project.id, action: "sync"})
    end

    {:ok, %{entries: entries, meta: meta}} = Resolver.list_project(project, %{page: 3}, %{})

    assert Enum.count(entries) == 30
    assert meta.current_page == 3
    assert meta.total_pages == 4
    assert meta.total_entries == 100
    assert meta.next_page == 4
    assert meta.previous_page == 2
  end

  test "list project from user", %{user: user, project: project} do
    other_user = Repo.insert!(%User{email: "foo@bar.com"})
    Repo.insert!(%Operation{user_id: other_user.id, project_id: project.id, action: "sync"})
    Repo.insert!(%Operation{user_id: user.id, project_id: project.id, action: "sync"})
    {:ok, %{entries: entries}} = Resolver.list_project(project, %{user_id: other_user.id}, %{})

    assert Enum.count(entries) == 1
  end

  test "list project from batch", %{user: user, project: project} do
    Repo.insert!(%Operation{user_id: user.id, project_id: project.id, action: "sync", batch: true})
    Repo.insert!(%Operation{user_id: user.id, project_id: project.id, action: "sync"})
    {:ok, %{entries: entries}} = Resolver.list_project(project, %{is_batch: true}, %{})

    assert Enum.count(entries) == 1
  end

  test "list project from action", %{user: user, project: project} do
    Repo.insert!(%Operation{user_id: user.id, project_id: project.id, action: "delete_document"})
    Repo.insert!(%Operation{user_id: user.id, project_id: project.id, action: "sync"})
    {:ok, %{entries: entries}} = Resolver.list_project(project, %{action: "sync"}, %{})

    assert Enum.count(entries) == 1
  end

  test "list translation", %{user: user, project: project, translation: translation, revision: revision} do
    Repo.insert!(%Operation{
      user_id: user.id,
      translation_id: translation.id,
      revision_id: revision.id,
      key: translation.key,
      text: "foo",
      action: "update"
    })

    Repo.insert!(%Operation{user_id: user.id, project_id: project.id, action: "sync"})
    {:ok, %{entries: entries, meta: meta}} = Resolver.list_translation(translation, %{}, %{})

    assert Enum.count(entries) == 1
    assert meta.current_page == 1
    assert meta.total_pages == 1
    assert meta.total_entries == 1
    assert meta.next_page == nil
    assert meta.previous_page == nil
  end

  test "list translation from user", %{user: user, translation: translation} do
    other_user = Repo.insert!(%User{email: "foo@bar.com"})
    Repo.insert!(%Operation{user_id: other_user.id, translation_id: translation.id, action: "update"})
    Repo.insert!(%Operation{user_id: user.id, translation_id: translation.id, action: "update"})
    {:ok, %{entries: entries}} = Resolver.list_translation(translation, %{user_id: other_user.id}, %{})

    assert Enum.count(entries) == 1
  end

  test "list translation from batch", %{user: user, translation: translation} do
    Repo.insert!(%Operation{user_id: user.id, translation_id: translation.id, action: "sync", batch: true})
    Repo.insert!(%Operation{user_id: user.id, translation_id: translation.id, action: "update"})
    {:ok, %{entries: entries}} = Resolver.list_translation(translation, %{is_batch: true}, %{})

    assert Enum.count(entries) == 1
  end

  test "list translation from action", %{user: user, translation: translation} do
    Repo.insert!(%Operation{user_id: user.id, translation_id: translation.id, action: "delete_document"})
    Repo.insert!(%Operation{user_id: user.id, translation_id: translation.id, action: "update"})
    {:ok, %{entries: entries}} = Resolver.list_translation(translation, %{action: "update"}, %{})

    assert Enum.count(entries) == 1
  end

  test "show project", %{user: user, project: project} do
    operation = Repo.insert!(%Operation{user_id: user.id, project_id: project.id, action: "sync"})

    {:ok, %{id: id}} = Resolver.show_project(project, %{id: operation.id}, %{})

    assert id == operation.id
  end
end
