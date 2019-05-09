defmodule AccentTest.CollaboratorCreator do
  use Accent.RepoCase

  alias Accent.{CollaboratorCreator, Project, Repo, User}

  test "create unknown email" do
    email = "test@test.com"
    project = %Project{main_color: "#f00", name: "com"} |> Repo.insert!()
    assigner = %User{email: "lol@test.com"} |> Repo.insert!()
    role = "admin"

    {:ok, collaborator} = CollaboratorCreator.create(%{"email" => email, "assigner_id" => assigner.id, "role" => role, "project_id" => project.id})

    assert collaborator.email === email
    assert collaborator.assigner_id === assigner.id
    assert collaborator.role === role
  end

  test "create known email" do
    email = "test@test.com"
    project = %Project{main_color: "#f00", name: "com"} |> Repo.insert!()
    user = %User{email: email} |> Repo.insert!()
    assigner = %User{email: "lol@test.com"} |> Repo.insert!()
    role = "admin"

    {:ok, collaborator} = CollaboratorCreator.create(%{"email" => email, "assigner_id" => assigner.id, "role" => role, "project_id" => project.id})

    assert collaborator.email === email
    assert collaborator.user_id === user.id
    assert collaborator.assigner_id === assigner.id
    assert collaborator.role === role
  end

  test "create invalid role" do
    email = "test@test.com"
    project = %Project{main_color: "#f00", name: "com"} |> Repo.insert!()
    assigner = %User{email: "lol@test.com"} |> Repo.insert!()
    role = "test123"

    {:error, collaborator} = CollaboratorCreator.create(%{"email" => email, "assigner_id" => assigner.id, "role" => role, "project_id" => project.id})

    assert collaborator.errors === [role: {"is invalid", [validation: :inclusion, enum: ["owner", "admin", "developer", "reviewer"]]}]
  end

  test "create with insensitive email" do
    email = "TEST@test.com"
    project = %Project{main_color: "#f00", name: "com"} |> Repo.insert!()
    assigner = %User{email: "lol@test.com"} |> Repo.insert!()
    role = "admin"

    {:ok, collaborator} = CollaboratorCreator.create(%{"email" => email, "assigner_id" => assigner.id, "role" => role, "project_id" => project.id})

    assert collaborator.email === "test@test.com"
  end
end
