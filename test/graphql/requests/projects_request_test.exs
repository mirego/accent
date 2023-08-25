defmodule AccentTest.GraphQL.Requests.Projects do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Collaborator
  alias Accent.Language
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
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

    Repo.insert!(%Collaborator{project_id: project.id, user_id: user.id, role: "admin"})
    revision = Repo.insert!(%Revision{language_id: french_language.id, project_id: project.id, master: true})

    {:ok, [user: user, project: project, language: french_language, revision: revision]}
  end

  test "list projects", %{user: user, project: project, revision: revision} do
    Repo.insert!(%Translation{revision_id: revision.id, key: "A", conflicted: true})
    Repo.insert!(%Translation{revision_id: revision.id, key: "B", conflicted: true})
    Repo.insert!(%Translation{revision_id: revision.id, key: "C", conflicted: false})

    {:ok, data} =
      Absinthe.run(
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
        """,
        Accent.GraphQL.Schema,
        context: %{conn: %Plug.Conn{assigns: %{current_user: user}}}
      )

    assert get_in(data, [:data, "viewer", "projects", "entries", Access.at(0), "id"]) === project.id
    assert get_in(data, [:data, "viewer", "projects", "entries", Access.at(0), "name"]) === project.name

    assert get_in(data, [:data, "viewer", "projects", "entries", Access.at(0), "lastSyncedAt"]) ===
             "2017-01-01T00:00:00Z"

    assert get_in(data, [:data, "viewer", "projects", "entries", Access.at(0), "translationsCount"]) === 3
    assert get_in(data, [:data, "viewer", "projects", "entries", Access.at(0), "reviewedCount"]) === 1
    assert get_in(data, [:data, "viewer", "projects", "entries", Access.at(0), "conflictsCount"]) === 2
  end
end
