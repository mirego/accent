defmodule AccentTest.GraphQL.Resolvers.Document do
  use Accent.RepoCase

  alias Accent.GraphQL.Resolvers.Document, as: Resolver

  alias Accent.{
    Document,
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
    document = %Document{project_id: project.id, path: "test", format: "json", updated_at: DateTime.from_unix!(1_432_560_368_868_569, :microsecond)} |> Repo.insert!()

    {:ok, [user: user, project: project, document: document, revision: revision]}
  end

  test "delete", %{document: document, revision: revision, user: user} do
    %Translation{revision_id: revision.id, document_id: document.id, key: "ok", corrected_text: "bar", proposed_text: "bar"} |> Repo.insert!()

    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}
    {:ok, result} = Resolver.delete(document, %{}, context)

    assert get_in(result, [:errors]) == nil
  end

  test "update with valid path", %{document: document, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}
    {:ok, result} = Resolver.update(document, %{path: "new-path"}, context)
    updated_document = Repo.get(Document, document.id)

    assert updated_document.path === "new-path"
    assert get_in(result, [:errors]) == nil
  end

  test "update with invalid path", %{document: document, user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}
    {:ok, result} = Resolver.update(document, %{path: ""}, context)
    updated_document = Repo.get(Document, document.id)

    assert updated_document.path === document.path
    assert get_in(result, [:errors]) == ["unprocessable_entity"]
  end

  test "update with existing path", %{document: document, project: project, user: user} do
    other_document = %Document{project_id: project.id, path: "test2", format: "json", updated_at: DateTime.add(document.updated_at, 3600, :second)} |> Repo.insert!()
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}
    {:ok, result} = Resolver.update(document, %{path: other_document.path}, context)
    updated_document = Repo.get(Document, document.id)

    assert updated_document.path === document.path
    assert get_in(result, [:errors]) == ["unprocessable_entity"]
  end

  test "show project", %{document: document, project: project, revision: revision} do
    %Translation{revision_id: revision.id, document_id: document.id, key: "ok", corrected_text: "bar", proposed_text: "bar", conflicted: false} |> Repo.insert!()

    {:ok, result} = Resolver.show_project(project, %{id: document.id}, %{})

    assert get_in(result, [Access.key(:id)]) == document.id
    assert get_in(result, [Access.key(:translations_count)]) == 1
    assert get_in(result, [Access.key(:conflicts_count)]) == 0
    assert get_in(result, [Access.key(:reviewed_count)]) == 1
  end

  test "list project", %{document: document, project: project, revision: revision} do
    other_document = %Document{project_id: project.id, path: "test2", format: "json", updated_at: DateTime.add(document.updated_at, 3600, :second)} |> Repo.insert!()
    _empty_document = %Document{project_id: project.id, path: "test3", format: "json"} |> Repo.insert!()

    %Translation{revision_id: revision.id, document_id: document.id, key: "ok", corrected_text: "bar", proposed_text: "bar", conflicted: false} |> Repo.insert!()
    %Translation{revision_id: revision.id, document_id: other_document.id, key: "ok", corrected_text: "bar", proposed_text: "bar", conflicted: true} |> Repo.insert!()

    {:ok, result} = Resolver.list_project(project, %{}, %{})

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [other_document.id, document.id]
    assert get_in(result, [:entries, Access.all(), Access.key(:translations_count)]) == [1, 1]
    assert get_in(result, [:entries, Access.all(), Access.key(:conflicts_count)]) == [1, 0]
    assert get_in(result, [:entries, Access.all(), Access.key(:reviewed_count)]) == [0, 1]
  end

  test "list project with many deleted documents", %{document: document, project: project, revision: revision} do
    %Translation{revision_id: revision.id, document_id: document.id, key: "ok", corrected_text: "bar", proposed_text: "bar", conflicted: false} |> Repo.insert!()

    for i <- 1..80 do
      %Document{project_id: project.id, path: "doc-#{i}", format: "json"} |> Repo.insert!()
    end

    {:ok, result} = Resolver.list_project(project, %{}, %{})

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [document.id]
    assert get_in(result, [:meta, Access.key(:total_entries)]) == 1
  end
end
