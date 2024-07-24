defmodule AccentTest.CollaboratorUpdater do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Collaborator
  alias Accent.CollaboratorUpdater
  alias Accent.Project
  alias Accent.User

  test "update" do
    project = Factory.insert(Project)
    assigner = Factory.insert(User)
    role = "admin"

    collaborator =
      Factory.insert(Collaborator, role: role, assigner_id: assigner.id, project_id: project.id, email: assigner.email)

    {:ok, updated_collaborator} = CollaboratorUpdater.update(collaborator, %{"role" => "reviewer"})

    assert updated_collaborator.email === collaborator.email
    assert updated_collaborator.assigner_id === collaborator.assigner_id
    assert updated_collaborator.role === "reviewer"
  end
end
