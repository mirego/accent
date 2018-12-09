defmodule AccentTest.UserRemote.Authenticator do
  use Accent.RepoCase

  alias Accent.UserRemote.Authenticator

  alias Accent.{
    Collaborator,
    Language,
    Project,
    Repo,
    User
  }

  test "grant token new user" do
    {:ok, user, token} = Authenticator.authenticate("dummy", "test@example.com")

    assert user.email == "test@example.com"
    assert token.user_id == user.id
  end

  test "grant token existing user" do
    {:ok, user, _token} = Authenticator.authenticate("dummy", "test@example.com")
    {:ok, existing_user, _token} = Authenticator.authenticate("dummy", "test@example.com")

    assert user.id == existing_user.id
  end

  test "normalize collaborators with email" do
    assigner = %User{email: "foo@example.com"} |> Repo.insert!()
    language = %Language{name: "french"} |> Repo.insert!()
    project = %Project{name: "My project", language_id: language.id} |> Repo.insert!()
    collaborator = %Collaborator{project_id: project.id, role: "admin", assigner_id: assigner.id, email: "test@example.com"} |> Repo.insert!()

    {:ok, user, _token} = Authenticator.authenticate("dummy", "test@example.com")
    updated_collaborator = Repo.get(Collaborator, collaborator.id)

    assert updated_collaborator.user_id == user.id
  end

  test "normalize collaborators with uppercased email" do
    assigner = %User{email: "foo@example.com"} |> Repo.insert!()
    language = %Language{name: "french"} |> Repo.insert!()
    project = %Project{name: "My project", language_id: language.id} |> Repo.insert!()
    collaborator = %Collaborator{project_id: project.id, role: "admin", assigner_id: assigner.id, email: "test@example.com"} |> Repo.insert!()

    {:ok, user, _token} = Authenticator.authenticate("dummy", "TeSt@eXamPle.com")
    updated_collaborator = Repo.get(Collaborator, collaborator.id)

    assert updated_collaborator.user_id == user.id
  end
end
