defmodule AccentTest.GraphQL.Resolvers.Lint do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.GraphQL.Resolvers.Lint, as: Resolver
  alias Accent.Language
  alias Accent.Lint.Message
  alias Accent.Lint.Replacement
  alias Accent.Project
  alias Accent.ProjectLintEntry
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User

  defmodule PlugConn do
    @moduledoc false
    defstruct [:assigns]
  end

  setup do
    user = Factory.insert(User)
    french_language = Factory.insert(Language)
    project = Factory.insert(Project)

    revision =
      Factory.insert(Revision, language_id: french_language.id, project_id: project.id, master: true, slug: "fr")

    context = %{context: %{conn: %PlugConn{assigns: %{current_user: user}}}}

    {:ok, [user: user, project: project, revision: revision, context: context]}
  end

  test "lint", %{revision: revision} do
    master_translation =
      Factory.insert(Translation,
        revision: revision,
        conflicted: false,
        key: "ok2",
        corrected_text: "bar foo",
        proposed_text: "bar"
      )

    translation =
      Factory.insert(Translation,
        revision: revision,
        master_translation: master_translation,
        conflicted: false,
        key: "ok",
        corrected_text: " bar foo",
        proposed_text: "bar"
      )

    {:ok, result} = Resolver.lint_batched_translation(translation, %{}, [])

    assert result === [
             %Message{
               replacement: %Replacement{value: "bar foo", label: "bar foo"},
               check: :leading_spaces,
               text: " bar foo"
             }
           ]
  end

  test "list_project", %{project: project, context: context} do
    entry = Factory.insert(ProjectLintEntry, project_id: project.id)
    other_project = Factory.insert(Project)
    _other_entry = Factory.insert(ProjectLintEntry, project_id: other_project.id)

    {:ok, paginated} = Resolver.list_project(project, %{}, context)

    assert Enum.map(paginated.entries, & &1.id) === [entry.id]
    assert paginated.meta.total_entries === 1
  end

  test "update_project_lint_entry", %{project: project, context: context} do
    entry =
      Factory.insert(ProjectLintEntry,
        project_id: project.id,
        type: :all,
        value: "old",
        check_ids: ["spelling"]
      )

    args = %{check_ids: ["url_count"], type: :key, value: "new"}

    {:ok, updated} = Resolver.update_project_lint_entry(entry, args, context)

    assert updated.id === entry.id
    assert updated.type === :key
    assert updated.value === "new"
    assert updated.check_ids === ["url_count"]
  end

  test "delete_project_lint_entry", %{project: project, context: context} do
    entry = Factory.insert(ProjectLintEntry, project_id: project.id)

    {:ok, deleted} = Resolver.delete_project_lint_entry(entry, %{}, context)

    assert deleted.id === entry.id
    assert Repo.get(ProjectLintEntry, entry.id) === nil
  end
end
