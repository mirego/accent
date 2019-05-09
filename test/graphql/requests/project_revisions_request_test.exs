defmodule AccentTest.GraphQL.Requests.ProjectRevisions do
  use Accent.RepoCase

  alias Accent.{
    Collaborator,
    Language,
    Project,
    Repo,
    Revision,
    User
  }

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    french_language = %Language{name: "french", slug: Ecto.UUID.generate()} |> Repo.insert!()
    project = %Project{main_color: "#f00", name: "My project", last_synced_at: DateTime.from_naive!(~N[2017-01-01T00:00:00], "Etc/UTC")} |> Repo.insert!()
    user = %{user | permissions: %{project.id => "admin"}}

    %Collaborator{project_id: project.id, user_id: user.id, role: "admin"} |> Repo.insert!()
    revision = %Revision{language_id: french_language.id, name: "foo", slug: "bar", project_id: project.id, master: true} |> Repo.insert!()

    {:ok, [user: user, project: project, revision: revision]}
  end

  test "show project master revision", %{user: user, project: project, revision: revision} do
    {:ok, data} =
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
      """
      |> Absinthe.run(Accent.GraphQL.Schema, context: %{conn: %Plug.Conn{assigns: %{current_user: user}}})

    assert get_in(data, [:data, "viewer", "project", "revision", "id"]) === revision.id
    assert get_in(data, [:data, "viewer", "project", "revision", "name"]) === revision.name
    assert get_in(data, [:data, "viewer", "project", "revision", "slug"]) === revision.slug
  end
end
