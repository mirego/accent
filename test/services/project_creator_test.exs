defmodule AccentTest.ProjectCreator do
  @moduledoc false
  use Accent.RepoCase

  alias Accent.Language
  alias Accent.ProjectCreator
  alias Accent.Repo
  alias Accent.User

  require Ecto.Query

  test "create with language and user" do
    language = Repo.insert!(%Language{name: "french"})
    user = Repo.insert!(%User{email: "lol@test.com"})
    params = %{"main_color" => "#f00", "name" => "OK", "language_id" => language.id}

    {:ok, project} = ProjectCreator.create(params: params, user: user)

    assert project.name === "OK"
    assert hd(project.revisions).project_id === project.id
    assert hd(project.revisions).language_id === language.id
    assert hd(project.revisions).master === true
  end

  test "create owner collaborator" do
    language = Repo.insert!(%Language{name: "french"})
    user = Repo.insert!(%User{email: "lol@test.com"})
    params = %{"main_color" => "#f00", "name" => "OK", "language_id" => language.id}

    {:ok, project} = ProjectCreator.create(params: params, user: user)
    owner_collaborator = project |> Ecto.assoc(:collaborators) |> Ecto.Query.where([c], c.role == "owner") |> Repo.one()

    assert owner_collaborator.user_id == user.id
  end

  test "create bot collaborator" do
    language = Repo.insert!(%Language{name: "french"})
    user = Repo.insert!(%User{email: "lol@test.com"})
    params = %{"main_color" => "#f00", "name" => "OK", "language_id" => language.id}

    {:ok, project} = ProjectCreator.create(params: params, user: user)
    bot_collaborator = project |> Ecto.assoc(:all_collaborators) |> Ecto.Query.where([c], c.role == "bot") |> Repo.one()
    bot_user = Repo.preload(bot_collaborator, :user).user
    bot_access = hd(Repo.preload(bot_collaborator, user: :access_tokens).user.access_tokens)

    refute is_nil(bot_collaborator.user_id)
    refute is_nil(bot_access.token)
    assert bot_user.bot === true
  end
end
