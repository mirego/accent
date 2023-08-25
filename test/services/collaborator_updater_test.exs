defmodule AccentTest.CollaboratorUpdater do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Collaborator
  alias Accent.CollaboratorUpdater
  alias Accent.Project
  alias Accent.Repo
  alias Accent.User

  test "update" do
    email = "test@test.com"
    project = Repo.insert!(%Project{main_color: "#f00", name: "com"})
    assigner = Repo.insert!(%User{email: "lol@test.com"})
    role = "admin"
    collaborator = Repo.insert!(%Collaborator{role: role, assigner: assigner, project: project, email: email})

    {:ok, updated_collaborator} = CollaboratorUpdater.update(collaborator, %{"role" => "reviewer"})

    assert updated_collaborator.email === collaborator.email
    assert updated_collaborator.assigner_id === collaborator.assigner.id
    assert updated_collaborator.role === "reviewer"
  end
end
