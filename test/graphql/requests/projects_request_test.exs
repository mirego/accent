defmodule AccentTest.GraphQL.Requests.Projects do
  use Accent.RepoCase

  alias Accent.{
    Collaborator,
    Language,
    Project,
    Repo,
    Revision,
    Translation,
    User
  }

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    french_language = %Language{name: "french", slug: Ecto.UUID.generate()} |> Repo.insert!()
    project = %Project{main_color: "#f00", name: "My project", last_synced_at: DateTime.from_naive!(~N[2017-01-01T00:00:00], "Etc/UTC")} |> Repo.insert!()

    %Collaborator{project_id: project.id, user_id: user.id, role: "admin"} |> Repo.insert!()
    revision = %Revision{language_id: french_language.id, project_id: project.id, master: true} |> Repo.insert!()

    {:ok, [user: user, project: project, language: french_language, revision: revision]}
  end

  test "list projects", %{user: user, project: project, revision: revision} do
    %Translation{revision_id: revision.id, key: "A", conflicted: true} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "B", conflicted: true} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "C", conflicted: false} |> Repo.insert!()

    {:ok, data} =
      """
      query {
        viewer {
          projects {
            entries {
              id
              name
              lastSyncedAt
              translationsCount
              conflictsCount
              reviewedCount
            }
          }
        }
      }
      """
      |> Absinthe.run(Accent.GraphQL.Schema, context: %{conn: %Plug.Conn{assigns: %{current_user: user}}})

    assert get_in(data, [:data, "viewer", "projects", "entries", Access.at(0), "id"]) === project.id
    assert get_in(data, [:data, "viewer", "projects", "entries", Access.at(0), "name"]) === project.name
    assert get_in(data, [:data, "viewer", "projects", "entries", Access.at(0), "lastSyncedAt"]) === "2017-01-01T00:00:00Z"
    assert get_in(data, [:data, "viewer", "projects", "entries", Access.at(0), "translationsCount"]) === 3
    assert get_in(data, [:data, "viewer", "projects", "entries", Access.at(0), "reviewedCount"]) === 1
    assert get_in(data, [:data, "viewer", "projects", "entries", Access.at(0), "conflictsCount"]) === 2
  end
end
