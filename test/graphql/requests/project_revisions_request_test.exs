defmodule AccentTest.GraphQL.Requests.ProjectRevisions do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Collaborator
  alias Accent.Language
  alias Accent.Project
  alias Accent.Revision
  alias Accent.User

  setup do
    user = Factory.insert(User)
    french_language = Factory.insert(Language)
    project = Factory.insert(Project, last_synced_at: DateTime.from_naive!(~N[2017-01-01T00:00:00], "Etc/UTC"))
    user = %{user | permissions: %{project.id => "admin"}}

    Factory.insert(Collaborator, project_id: project.id, user_id: user.id, role: "admin")

    revision =
      Factory.insert(Revision,
        language_id: french_language.id,
        name: "foo",
        slug: "bar",
        project_id: project.id,
        master: true
      )

    {:ok, [user: user, project: project, revision: revision]}
  end

  test "show project master revision", %{user: user, project: project, revision: revision} do
    {:ok, data} =
      Absinthe.run(
        """
        query {
          viewer {
            project(id: "#{project.id}") {
              revision {
                id
                name
                slug
              }
            }
          }
        }
        """,
        Accent.GraphQL.Schema,
        context: %{conn: %Plug.Conn{assigns: %{current_user: user}}}
      )

    assert get_in(data, [:data, "viewer", "project", "revision", "id"]) === revision.id
    assert get_in(data, [:data, "viewer", "project", "revision", "name"]) === revision.name
    assert get_in(data, [:data, "viewer", "project", "revision", "slug"]) === revision.slug
  end
end
