defmodule AccentTest.GraphQL.Resolvers.Project do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.GraphQL.Resolvers.Project, as: Resolver
  alias Accent.Language
  alias Accent.Operation
  alias Accent.Project
  alias Accent.ProjectCreator
  alias Accent.Repo
  alias Accent.Translation
  alias Accent.User
  alias Accent.Version

  defmodule PlugConn do
    @moduledoc false
    defstruct [:assigns]
  end

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})

    {:ok, project} =
      ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)

    user = %{user | permissions: %{project.id => "owner"}}

    {:ok,
     [
       project: project,
       language: language,
       user: user
     ]}
  end

  test "list viewer", %{user: user, project: project} do
    Repo.insert!(%Project{main_color: "#f00", name: "Other project"})

    {:ok, result} = Resolver.list_viewer(user, %{}, %{})

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [project.id]
    assert get_in(result, [:meta, Access.key(:current_page)]) == 1
    assert get_in(result, [:meta, Access.key(:total_pages)]) == 1
    assert get_in(result, [:meta, Access.key(:total_entries)]) == 1
    assert get_in(result, [:meta, Access.key(:next_page)]) == nil
    assert get_in(result, [:meta, Access.key(:previous_page)]) == nil
  end

  test "list viewer search", %{user: user, language: language} do
    Repo.insert!(%Project{main_color: "#f00", name: "Other project"})

    {:ok, project_two} =
      ProjectCreator.create(
        params: %{main_color: "#f00", name: "My second project", language_id: language.id},
        user: user
      )

    ProjectCreator.create(params: %{main_color: "#f00", name: "My third project", language_id: language.id}, user: user)

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
      ProjectCreator.create(
        params: %{main_color: "#f00", name: "My project #{index}", language_id: language.id},
        user: user
      )
    end

    {:ok, %{entries: entries, meta: meta}} = Resolver.list_viewer(user, %{}, %{})

    assert Enum.count(entries) == 30
    assert meta.current_page == 1
    assert meta.total_pages == 2
    assert meta.total_entries == 51
    assert meta.next_page == 2
    assert meta.previous_page == nil
  end

  test "list viewer paginated page 2", %{user: user, language: language} do
    for index <- 1..50 do
      ProjectCreator.create(
        params: %{main_color: "#f00", name: "My project #{index}", language_id: language.id},
        user: user
      )
    end

    {:ok, %{entries: entries, meta: meta}} = Resolver.list_viewer(user, %{page: 2}, %{})

    assert Enum.count(entries) == 21
    assert meta.current_page == 2
    assert meta.total_pages == 2
    assert meta.total_entries == 51
    assert meta.next_page == nil
    assert meta.previous_page == 1
  end

  test "list viewer ordering", %{user: user, language: language, project: project_one} do
    Repo.insert!(%Project{main_color: "#f00", name: "Other project"})

    {:ok, project_two} =
      ProjectCreator.create(
        params: %{main_color: "#f00", name: "X - My second project", language_id: language.id},
        user: user
      )

    {:ok, project_three} =
      ProjectCreator.create(
        params: %{main_color: "#f00", name: "A - My third project", language_id: language.id},
        user: user
      )

    {:ok, result} = Resolver.list_viewer(user, %{}, %{})

    assert get_in(result, [:entries, Access.all(), Access.key(:id)]) == [
             project_three.id,
             project_one.id,
             project_two.id
           ]
  end

  test "show viewer", %{user: user, project: project} do
    {:ok, result} = Resolver.show_viewer(user, %{id: project.id}, %{})

    assert result.id == project.id
  end

  test "create", %{user: user, language: language} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} =
      Resolver.create(nil, %{main_color: "#f00", language_id: language.id, name: "Foo bar", logo: nil}, context)

    assert get_in(result, [:project, Access.key(:name)]) == "Foo bar"
  end

  test "create without name", %{user: user, language: language} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.create(nil, %{main_color: "#f00", language_id: language.id, name: "", logo: nil}, context)

    assert get_in(result, [:project]) == nil
    assert get_in(result, [:errors]) == ["unprocessable_entity"]
  end

  test "create without language", %{user: user} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.create(nil, %{main_color: "#f00", language_id: nil, name: "FOO", logo: nil}, context)

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

    {:ok, result} = Resolver.update(project, %{main_color: "#f00", name: "Foo bar", logo: "😀"}, context)

    assert get_in(result, [:project, Access.key(:name)]) == "Foo bar"
    assert get_in(result, [:project, Access.key(:main_color)]) == "#f00"
    assert get_in(result, [:project, Access.key(:logo)]) == "😀"
  end

  test "update with file operation locked", %{user: user, project: project} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} =
      Resolver.update(
        project,
        %{main_color: project.main_color, name: project.name, is_file_operations_locked: true, logo: nil},
        context
      )

    assert get_in(result, [:project, Access.key(:locked_file_operations)]) == true
  end

  test "get latest activity", %{user: user, project: project} do
    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}
    operation = Repo.insert!(%Operation{user_id: user.id, project_id: project.id, action: "sync"})

    {:ok, latest_activity} = Resolver.last_activity(project, %{}, context)

    assert latest_activity.id === operation.id
  end

  test "lint_translations", %{user: user, project: project} do
    [revision] = project.revisions
    Repo.insert!(%Translation{revision_id: revision.id, key: "a", proposed_text: " A", corrected_text: " A"})

    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, [lint]} = Resolver.lint_translations(project, %{revision_id: nil, rule_ids: [], query: nil}, context)

    assert lint.messages === [
             %Accent.Lint.Message{
               check: :leading_spaces,
               text: " A",
               replacement: %Accent.Lint.Replacement{value: "A", label: "A"}
             }
           ]
  end

  test "lint_translations on current version only", %{user: user, project: project} do
    [revision] = project.revisions
    version = Repo.insert!(%Version{project_id: project.id, name: "foo", tag: "bar", user_id: user.id})
    Repo.insert!(%Translation{revision_id: revision.id, key: "a", proposed_text: " A", corrected_text: " A"})

    Repo.insert!(%Translation{
      version_id: version.id,
      revision_id: revision.id,
      key: "b",
      proposed_text: " B",
      corrected_text: " B"
    })

    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, result} = Resolver.lint_translations(project, %{revision_id: nil, rule_ids: [], query: nil}, context)

    assert Enum.count(result) === 1
  end
end
