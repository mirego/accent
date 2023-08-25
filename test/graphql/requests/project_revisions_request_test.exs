defmodule AccentTest.GraphQL.Requests.ProjectRevisions do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Collaborator
  alias Accent.Language
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.User

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    french_language = Repo.insert!(%Language{name: "french", slug: Ecto.UUID.generate()})

    project =
      Repo.insert!(%Project{
        main_color: "#f00",
        name: "My project",
        last_synced_at: DateTime.from_naive!(~N[2017-01-01T00:00:00], "Etc/UTC")
      })

    user = %{user | permissions: %{project.id => "admin"}}

    Repo.insert!(%Collaborator{project_id: project.id, user_id: user.id, role: "admin"})

    revision =
      Repo.insert!(%Revision{
        language_id: french_language.id,
        name: "foo",
        slug: "bar",
        project_id: project.id,
        master: true
      })

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
