defmodule AccentTest.UserRemote.Authenticator do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Collaborator
  alias Accent.Language
  alias Accent.Project
  alias Accent.Repo
  alias Accent.User
  alias Accent.UserRemote.Authenticator

  test "grant token new user" do
    {:ok, token} = Authenticator.authenticate(%{provider: :dummy, info: %{email: "test@example.com"}})
    user = Repo.get_by(User, email: "test@example.com")

    assert user.email == "test@example.com"
    assert token.user_id == user.id
  end

  test "grant token existing user" do
    {:ok, _token} = Authenticator.authenticate(%{provider: :dummy, info: %{email: "test@example.com"}})
    {:ok, _token} = Authenticator.authenticate(%{provider: :dummy, info: %{email: "test@example.com"}})

    assert Repo.get_by(User, email: "test@example.com")
  end

  test "normalize collaborators with email" do
    assigner = Factory.insert(User, email: "foo@example.com")
    language = Factory.insert(Language)
    project = Factory.insert(Project, language_id: language.id)

    collaborator =
      Repo.insert!(%Collaborator{
        project_id: project.id,
        role: "admin",
        assigner_id: assigner.id,
        email: "test@example.com"
      })

    {:ok, _token} = Authenticator.authenticate(%{provider: :dummy, info: %{email: "test@example.com"}})
    user = Repo.get_by(User, email: "test@example.com")
    updated_collaborator = Repo.get(Collaborator, collaborator.id)

    assert updated_collaborator.user_id == user.id
  end

  test "normalize collaborators with uppercased email" do
    assigner = Factory.insert(User, email: "foo@example.com")
    language = Factory.insert(Language)
    project = Factory.insert(Project, language_id: language.id)

    collaborator =
      Repo.insert!(%Collaborator{
        project_id: project.id,
        role: "admin",
        assigner_id: assigner.id,
        email: "test@example.com"
      })

    {:ok, _token} = Authenticator.authenticate(%{provider: :dummy, info: %{email: "TeSt@eXamPle.com"}})
    user = Repo.get_by(User, email: "test@example.com")
    updated_collaborator = Repo.get(Collaborator, collaborator.id)

    assert updated_collaborator.user_id == user.id
  end
end
