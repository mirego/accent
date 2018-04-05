defmodule AccentTest.ProjectCreator do
  use Accent.RepoCase
  require Ecto.Query

  alias Accent.{Repo, Language, User, ProjectCreator}

  test "create with language and user" do
    language = %Language{name: "french"} |> Repo.insert!()
    user = %User{email: "lol@test.com"} |> Repo.insert!()
    params = %{"name" => "OK", "language_id" => language.id}

    {:ok, project} = ProjectCreator.create(params: params, user: user)

    assert project.name === "OK"
    assert Enum.at(project.revisions, 0).project_id === project.id
    assert Enum.at(project.revisions, 0).language_id === language.id
    assert Enum.at(project.revisions, 0).master === true
  end

  test "create owner collaborator" do
    language = %Language{name: "french"} |> Repo.insert!()
    user = %User{email: "lol@test.com"} |> Repo.insert!()
    params = %{"name" => "OK", "language_id" => language.id}

    {:ok, project} = ProjectCreator.create(params: params, user: user)
    owner_collaborator = project |> Ecto.assoc(:collaborators) |> Ecto.Query.where([c], c.role == "owner") |> Repo.one()

    assert owner_collaborator.user_id == user.id
  end

  test "create bot collaborator" do
    language = %Language{name: "french"} |> Repo.insert!()
    user = %User{email: "lol@test.com"} |> Repo.insert!()
    params = %{"name" => "OK", "language_id" => language.id}

    {:ok, project} = ProjectCreator.create(params: params, user: user)
    bot_collaborator = project |> Ecto.assoc(:collaborators) |> Ecto.Query.where([c], c.role == "bot") |> Repo.one()
    bot_user = Repo.preload(bot_collaborator, :user).user
    bot_access = Repo.preload(bot_collaborator, user: :access_tokens).user.access_tokens |> Enum.at(0)

    refute is_nil(bot_collaborator.user_id)
    refute is_nil(bot_access.token)
    assert bot_user.bot === true
  end
end
