defmodule AccentTest.GraphQL.Resolvers.Project do
  use Accent.RepoCase

  alias Accent.GraphQL.Resolvers.Project, as: Resolver

  alias Accent.{
    Repo,
    ProjectCreator,
    Project,
    User,
    Language
  }

  defmodule PlugConn do
    defstruct [:assigns]
  end

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})
    {:ok, project} = ProjectCreator.create(params: %{name: "My project", language_id: language.id}, user: user)
    user = %{user | permissions: %{project.id => "owner"}}

    {:ok,
     [
       project: project,
       language: language,
       user: user
     ]}
  end

  test "list viewer", %{user: user, project: project} do
    Repo.insert!(%Project{name: "Other project"})

    {:ok, result} = Resolver.list_viewer(user, %{}, %{})

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [project.id]
    assert get_in(result, [:meta, Access.key(:current_page)]) == 1
    assert get_in(result, [:meta, Access.key(:total_pages)]) == 1
    assert get_in(result, [:meta, Access.key(:total_entries)]) == 1
    assert get_in(result, [:meta, Access.key(:next_page)]) == nil
    assert get_in(result, [:meta, Access.key(:previous_page)]) == nil
  end

  test "list viewer search", %{user: user, language: language} do
    Repo.insert!(%Project{name: "Other project"})
    {:ok, project_two} = ProjectCreator.create(params: %{name: "My second project", language_id: language.id}, user: user)
    ProjectCreator.create(params: %{name: "My third project", language_id: language.id}, user: user)

    {:ok, result} = Resolver.list_viewer(user, %{query: "second"}, %{})

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [project_two.id]
  end

  test "list viewer empty search", %{user: user, project: project} do
    {:ok, result} = Resolver.list_viewer(user, %{query: ""}, %{})

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [project.id]
    assert get_in(result, [:meta, Access.key(:current_page)]) == 1
    assert get_in(result, [:meta, Access.key(:total_pages)]) == 1
    assert get_in(result, [:meta, Access.key(:total_entries)]) == 1
    assert get_in(result, [:meta, Access.key(:next_page)]) == nil
    assert get_in(result, [:meta, Access.key(:previous_page)]) == nil
  end

  test "list viewer paginated", %{user: user, language: language} do
    for index <- 1..50 do
      ProjectCreator.create(params: %{name: "My project #{index}", language_id: language.id}, user: user)
    end

    {:ok, %{entries: entries, meta: meta}} = Resolver.list_viewer(user, %{}, %{})

    assert entries |> Enum.count() == 30
    assert meta.current_page == 1
    assert meta.total_pages == 2
    assert meta.total_entries == 51
    assert meta.next_page == 2
    assert meta.previous_page == nil
  end

  test "list viewer paginated page 2", %{user: user, language: language} do
    for index <- 1..50 do
      ProjectCreator.create(params: %{name: "My project #{index}", language_id: language.id}, user: user)
    end

    {:ok, %{entries: entries, meta: meta}} = Resolver.list_viewer(user, %{page: 2}, %{})

    assert entries |> Enum.count() == 21
    assert meta.current_page == 2
    assert meta.total_pages == 2
    assert meta.total_entries == 51
    assert meta.next_page == nil
    assert meta.previous_page == 1
  end

  test "list viewer ordering", %{user: user, language: language, project: project_one} do
    Repo.insert!(%Project{name: "Other project"})
    {:ok, project_two} = ProjectCreator.create(params: %{name: "X - My second project", language_id: language.id}, user: user)
    {:ok, project_three} = ProjectCreator.create(params: %{name: "A - My third project", language_id: language.id}, user: user)

    {:ok, result} = Resolver.list_viewer(user, %{}, %{})

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [project_three.id, project_one.id, project_two.id]
  end

  test "show viewer", %{user: user, project: project} do
    {:ok, result} = Resolver.show_viewer(user, %{id: project.id}, %{})

    assert result.id == project.id
  end

  test "create", %{user: user, language: language} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.create(nil, %{language_id: language.id, name: "Foo bar"}, context)

    assert get_in(result, [:project, Access.key(:name)]) == "Foo bar"
  end

  test "create without name", %{user: user, language: language} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.create(nil, %{language_id: language.id, name: ""}, context)

    assert get_in(result, [:project]) == nil
    assert get_in(result, [:errors]) == ["unprocessable_entity"]
  end

  test "create without language", %{user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.create(nil, %{language_id: nil, name: "FOO"}, context)

    assert get_in(result, [:project]) == nil
    assert get_in(result, [:errors]) == ["unprocessable_entity"]
  end

  test "delete", %{user: user, project: project} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.delete(project, %{}, context)

    assert Repo.all(Ecto.assoc(project, :collaborators)) === []
    assert get_in(result, [:project]) == project
  end

  test "update", %{user: user, project: project} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.update(project, %{name: "Foo bar"}, context)

    assert get_in(result, [:project, Access.key(:name)]) == "Foo bar"
  end

  test "update with file operation locked", %{user: user, project: project} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.update(project, %{name: project.name, is_file_operations_locked: true}, context)

    assert get_in(result, [:project, Access.key(:locked_file_operations)]) == true
  end
end
