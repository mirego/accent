defmodule AccentTest.CollaboratorCreator do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Collaborator
  alias Accent.CollaboratorCreator
  alias Accent.Project
  alias Accent.Repo
  alias Accent.User

  test "create unknown email" do
    email = "test@test.com"
    project = Repo.insert!(%Project{main_color: "#f00", name: "com"})
    assigner = Repo.insert!(%User{email: "lol@test.com"})
    role = "admin"

    {:ok, collaborator} =
      CollaboratorCreator.create(%{
        "email" => email,
        "assigner_id" => assigner.id,
        "role" => role,
        "project_id" => project.id
      })

    assert collaborator.email === email
    assert collaborator.assigner_id === assigner.id
    assert collaborator.role === role
  end

  test "create known email" do
    email = "test@test.com"
    project = Repo.insert!(%Project{main_color: "#f00", name: "com"})
    user = Repo.insert!(%User{email: email})
    assigner = Repo.insert!(%User{email: "lol@test.com"})
    role = "admin"

    {:ok, collaborator} =
      CollaboratorCreator.create(%{
        "email" => email,
        "assigner_id" => assigner.id,
        "role" => role,
        "project_id" => project.id
      })

    assert collaborator.email === email
    assert collaborator.user_id === user.id
    assert collaborator.assigner_id === assigner.id
    assert collaborator.role === role
  end

  test "create invalid role" do
    email = "test@test.com"
    project = Repo.insert!(%Project{main_color: "#f00", name: "com"})
    assigner = Repo.insert!(%User{email: "lol@test.com"})
    role = "test123"

    {:error, collaborator} =
      CollaboratorCreator.create(%{
        "email" => email,
        "assigner_id" => assigner.id,
        "role" => role,
        "project_id" => project.id
      })

    assert collaborator.errors === [
             role:
               {"is invalid", [validation: :inclusion, enum: ["owner", "admin", "developer", "reviewer", "translator"]]}
           ]
  end

  test "create with insensitive email" do
    email = "TEST@test.com"
    project = Repo.insert!(%Project{main_color: "#f00", name: "com"})
    assigner = Repo.insert!(%User{email: "lol@test.com"})
    role = "admin"

    {:ok, collaborator} =
      CollaboratorCreator.create(%{
        "email" => email,
        "assigner_id" => assigner.id,
        "role" => role,
        "project_id" => project.id
      })

    assert collaborator.email === "test@test.com"
  end

  test "create with leading and trailing spaces in email" do
    email = "    test@test.com   "
    project = Repo.insert!(%Project{main_color: "#f00", name: "com"})
    assigner = Repo.insert!(%User{email: "lol@test.com"})
    role = "admin"

    {:ok, collaborator} =
      CollaboratorCreator.create(%{
        "email" => email,
        "assigner_id" => assigner.id,
        "role" => role,
        "project_id" => project.id
      })

    assert collaborator.email === "test@test.com"
  end

  test "cannot create with already used email for project" do
    email = "test@test.com"
    project = Repo.insert!(%Project{main_color: "#f00", name: "com"})
    assigner = Repo.insert!(%User{email: "lol@test.com"})
    role = "admin"
    Repo.insert!(%Collaborator{email: email, assigner_id: assigner.id, role: role, project_id: project.id})

    {:error, changeset} =
      CollaboratorCreator.create(%{
        "email" => email,
        "assigner_id" => assigner.id,
        "role" => role,
        "project_id" => project.id
      })

    assert changeset.errors === [
             email:
               {"has already been taken",
                [
                  constraint: :unique,
                  constraint_name: "collaborators_email_project_id_index"
                ]}
           ]
  end
end
