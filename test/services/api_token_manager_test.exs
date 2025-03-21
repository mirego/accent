defmodule AccentTest.APITokenManager do
  @moduledoc false
  use Accent.RepoCase, async: false

  alias Accent.AccessToken
  alias Accent.APITokenManager
  alias Accent.Collaborator
  alias Accent.Project
  alias Accent.Repo
  alias Accent.RoleAbilities
  alias Accent.User

  describe "create/3" do
    setup do
      project = Factory.insert(Project)
      user = Factory.insert(User)
      user = %{user | permissions: %{project.id => "developer"}}

      {:ok, [project: project, user: user]}
    end

    test "creates an access token with valid permissions", %{project: project, user: user} do
      params = %{
        name: "API Token",
        picture_url: "https://example.com/bot.png",
        permissions: ["format"]
      }

      {:ok, result} = APITokenManager.create(project, user, params)

      assert %{access_token: access_token, collaborator: collaborator} = result

      # Assert access token is created correctly
      assert access_token.token
      assert access_token.custom_permissions == ["format"]
      assert access_token.revoked_at == nil

      # Assert user is created correctly
      bot_user = Repo.get!(User, access_token.user_id)
      assert bot_user.fullname == "API Token"
      assert bot_user.picture_url == "https://example.com/bot.png"
      assert bot_user.bot == true

      # Assert collaborator is created correctly
      assert collaborator.user_id == bot_user.id
      assert collaborator.project_id == project.id
      assert collaborator.role == "bot"
      assert collaborator.assigner_id == user.id
    end

    test "fails with escalated permissions", %{project: project, user: user} do
      params = %{
        name: "API Token",
        picture_url: "https://example.com/bot.png",
        permissions: ["delete_project"]
      }

      result = APITokenManager.create(project, user, params)

      assert {:error, :access_token, changeset, _} = result
      assert {"has an invalid entry", _} = changeset.errors[:custom_permissions]
    end

    test "fails with invalid permissions", %{project: project, user: user} do
      params = %{
        name: "API Token",
        picture_url: "https://example.com/bot.png",
        permissions: ["invalid_permission"]
      }

      result = APITokenManager.create(project, user, params)

      assert {:error, :access_token, changeset, _} = result
      assert {"has an invalid entry", _} = changeset.errors[:custom_permissions]
    end
  end

  describe "revoke/1" do
    setup do
      project = Factory.insert(Project)
      user = Factory.insert(User)
      user = %{user | permissions: %{project.id => "admin"}}

      valid_permissions = Enum.map(RoleAbilities.actions_for(:all, project), &to_string/1)

      params = %{
        name: "API Token",
        picture_url: "https://example.com/bot.png",
        permissions: [hd(valid_permissions)]
      }

      {:ok, result} = APITokenManager.create(project, user, params)
      access_token = result.access_token

      {:ok, [access_token: access_token]}
    end

    test "revokes an access token", %{access_token: access_token} do
      assert :ok = APITokenManager.revoke(access_token)

      assert Repo.get(AccessToken, access_token.id) == nil
    end
  end

  describe "list/2" do
    setup do
      project = Factory.insert(Project)
      bot = Factory.insert(User, bot: true)
      user = Factory.insert(User)
      admin_user = Factory.insert(User)

      Factory.insert(Collaborator, project_id: project.id, user_id: bot.id, role: "bot")
      Factory.insert(Collaborator, project_id: project.id, user_id: admin_user.id, role: "admin")
      Factory.insert(Collaborator, project_id: project.id, user_id: user.id, role: "developer")

      admin_user = %{admin_user | permissions: %{project.id => "admin"}}
      user = %{user | permissions: %{project.id => "developer"}}

      {:ok,
       [
         project: project,
         user: user,
         bot: bot,
         admin_user: admin_user
       ]}
    end

    test "admin user can see all tokens", %{project: project, admin_user: admin_user, bot: bot} do
      Factory.insert(AccessToken, user_id: bot.id, custom_permissions: ["delete_project"])

      tokens = APITokenManager.list(project, admin_user)

      assert length(tokens) == 1
    end

    test "regular user can only see tokens with permissions they have", %{project: project, user: user, bot: bot} do
      Factory.insert(AccessToken, user_id: bot.id, custom_permissions: ["delete_project"])

      tokens = APITokenManager.list(project, user)

      assert Enum.empty?(tokens)
    end
  end
end
