defmodule AccentTest.CollaboratorUpdater do
  use Accent.RepoCase

  alias Accent.{Collaborator, CollaboratorUpdater, Project, Repo, User}

  test "update" do
    email = "test@test.com"
    project = %Project{main_color: "#f00", name: "com"} |> Repo.insert!()
    assigner = %User{email: "lol@test.com"} |> Repo.insert!()
    role = "admin"
    collaborator = %Collaborator{role: role, assigner: assigner, project: project, email: email} |> Repo.insert!()

    {:ok, updated_collaborator} = CollaboratorUpdater.update(collaborator, %{"role" => "reviewer"})

    assert updated_collaborator.email === collaborator.email
    assert updated_collaborator.assigner_id === collaborator.assigner.id
    assert updated_collaborator.role === "reviewer"
  end
end
