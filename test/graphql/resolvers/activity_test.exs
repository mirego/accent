defmodule AccentTest.GraphQL.Resolvers.Activity do
  use Accent.RepoCase, async: true
  doctest Accent.GraphQL.Resolvers.Activity, import: true

  alias Accent.GraphQL.Resolvers.Activity, as: Resolver

  alias Accent.{
    Language,
    Operation,
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
    language = %Language{name: "french"} |> Repo.insert!()
    project = %Project{main_color: "#f00", name: "My project"} |> Repo.insert!()

    revision = %Revision{language_id: language.id, project_id: project.id, master: true} |> Repo.insert!()
    translation = %Translation{revision_id: revision.id, key: "ok", corrected_text: "bar", proposed_text: "bar"} |> Repo.insert!()

    {:ok, [user: user, project: project, revision: revision, translation: translation]}
  end

  test "list activities", %{user: user, project: project, translation: translation, revision: revision} do
    operation = %Operation{user_id: user.id, project_id: project.id, action: "sync"} |> Repo.insert!()

    %Operation{user_id: user.id, translation_id: translation.id, revision_id: revision.id, key: translation.key, text: "foo", action: "update", batch_operation_id: operation.id}
    |> Repo.insert!()

    {:ok, %{entries: entries, meta: meta}} = Resolver.list_operations(operation, %{}, %{})

    assert entries |> Enum.count() == 1
    assert meta.current_page == 1
    assert meta.total_pages == 1
    assert meta.total_entries == 1
    assert meta.next_page == nil
    assert meta.previous_page == nil
  end

  test "list project", %{user: user, project: project, translation: translation, revision: revision} do
    %Operation{user_id: user.id, translation_id: translation.id, revision_id: revision.id, key: translation.key, text: "foo", action: "update"} |> Repo.insert!()
    %Operation{user_id: user.id, project_id: project.id, action: "sync"} |> Repo.insert!()
    {:ok, %{entries: entries, meta: meta}} = Resolver.list_project(project, %{}, %{})

    assert entries |> Enum.count() == 2
    assert meta.current_page == 1
    assert meta.total_pages == 1
    assert meta.total_entries == 2
    assert meta.next_page == nil
    assert meta.previous_page == nil
  end

  test "list project paginated", %{user: user, project: project} do
    for _index <- 1..100 do
      %Operation{user_id: user.id, project_id: project.id, action: "sync"} |> Repo.insert!()
    end

    {:ok, %{entries: entries, meta: meta}} = Resolver.list_project(project, %{page: 3}, %{})

    assert entries |> Enum.count() == 30
    assert meta.current_page == 3
    assert meta.total_pages == 4
    assert meta.total_entries == 100
    assert meta.next_page == 4
    assert meta.previous_page == 2
  end

  test "list project from user", %{user: user, project: project} do
    other_user = %User{email: "foo@bar.com"} |> Repo.insert!()
    %Operation{user_id: other_user.id, project_id: project.id, action: "sync"} |> Repo.insert!()
    %Operation{user_id: user.id, project_id: project.id, action: "sync"} |> Repo.insert!()

    {:ok, %{entries: entries}} = Resolver.list_project(project, %{user_id: other_user.id}, %{})

    assert entries |> Enum.count() == 1
  end

  test "list project from batch", %{user: user, project: project} do
    %Operation{user_id: user.id, project_id: project.id, action: "sync", batch: true} |> Repo.insert!()
    %Operation{user_id: user.id, project_id: project.id, action: "sync"} |> Repo.insert!()

    {:ok, %{entries: entries}} = Resolver.list_project(project, %{is_batch: true}, %{})

    assert entries |> Enum.count() == 1
  end

  test "list project from action", %{user: user, project: project} do
    %Operation{user_id: user.id, project_id: project.id, action: "delete_document"} |> Repo.insert!()
    %Operation{user_id: user.id, project_id: project.id, action: "sync"} |> Repo.insert!()

    {:ok, %{entries: entries}} = Resolver.list_project(project, %{action: "sync"}, %{})

    assert entries |> Enum.count() == 1
  end

  test "list translation", %{user: user, project: project, translation: translation, revision: revision} do
    %Operation{user_id: user.id, translation_id: translation.id, revision_id: revision.id, key: translation.key, text: "foo", action: "update"} |> Repo.insert!()
    %Operation{user_id: user.id, project_id: project.id, action: "sync"} |> Repo.insert!()
    {:ok, %{entries: entries, meta: meta}} = Resolver.list_translation(translation, %{}, %{})

    assert entries |> Enum.count() == 1
    assert meta.current_page == 1
    assert meta.total_pages == 1
    assert meta.total_entries == 1
    assert meta.next_page == nil
    assert meta.previous_page == nil
  end

  test "list translation from user", %{user: user, translation: translation} do
    other_user = %User{email: "foo@bar.com"} |> Repo.insert!()
    %Operation{user_id: other_user.id, translation_id: translation.id, action: "update"} |> Repo.insert!()
    %Operation{user_id: user.id, translation_id: translation.id, action: "update"} |> Repo.insert!()

    {:ok, %{entries: entries}} = Resolver.list_translation(translation, %{user_id: other_user.id}, %{})

    assert entries |> Enum.count() == 1
  end

  test "list translation from batch", %{user: user, translation: translation} do
    %Operation{user_id: user.id, translation_id: translation.id, action: "sync", batch: true} |> Repo.insert!()
    %Operation{user_id: user.id, translation_id: translation.id, action: "update"} |> Repo.insert!()

    {:ok, %{entries: entries}} = Resolver.list_translation(translation, %{is_batch: true}, %{})

    assert entries |> Enum.count() == 1
  end

  test "list translation from action", %{user: user, translation: translation} do
    %Operation{user_id: user.id, translation_id: translation.id, action: "delete_document"} |> Repo.insert!()
    %Operation{user_id: user.id, translation_id: translation.id, action: "update"} |> Repo.insert!()

    {:ok, %{entries: entries}} = Resolver.list_translation(translation, %{action: "update"}, %{})

    assert entries |> Enum.count() == 1
  end

  test "show project", %{user: user, project: project} do
    operation = %Operation{user_id: user.id, project_id: project.id, action: "sync"} |> Repo.insert!()

    {:ok, %{id: id}} = Resolver.show_project(project, %{id: operation.id}, %{})

    assert id == operation.id
  end
end
