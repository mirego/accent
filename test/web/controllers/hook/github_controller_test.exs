defmodule AccentTest.Hook.GitHubController do
  use Accent.ConnCase
  use Oban.Testing, repo: Accent.Repo

  alias Accent.AccessToken
  alias Accent.Collaborator
  alias Accent.Integration
  alias Accent.Project
  alias Accent.Repo
  alias Accent.User

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    access_token = Repo.insert!(%AccessToken{user_id: user.id, token: "test-token"})
    project = Repo.insert!(%Project{main_color: "#f00", name: "My project"})
    Repo.insert!(%Collaborator{project_id: project.id, user_id: user.id, role: "bot"})
    {:ok, [access_token: access_token, user: user, project: project]}
  end

  test "acknowledge ping", %{access_token: access_token, conn: conn, project: project} do
    params = %{
      "ref" => "refs/heads/master",
      "repository" => %{
        "full_name" => "accent/test-repo"
      }
    }

    response =
      conn
      |> put_req_header("x-github-event", "ping")
      |> post(hooks_github_path(conn, []) <> "?authorization=#{access_token.token}&project_id=#{project.id}", params)

    assert response.status == 200
    assert response.resp_body == "pong"
  end

  test "broadcast event on push", %{user: user, access_token: access_token, conn: conn, project: project} do
    params = %{
      "ref" => "refs/heads/master",
      "repository" => %{
        "full_name" => "accent/test-repo"
      }
    }

    data = %{default_ref: "master", repository: "accent/test-repo", token: "1234"}
    Repo.insert!(%Integration{project_id: project.id, user_id: user.id, service: "github", data: data})

    response =
      conn
      |> put_req_header("x-github-event", "push")
      |> post(hooks_github_path(conn, []) <> "?authorization=#{access_token.token}&project_id=#{project.id}", params)

    assert response.status == 204

    assert_enqueued(
      worker: Accent.Hook.Inbounds.Mock,
      args: %{
        "event" => "sync",
        "payload" => %{
          "default_ref" => "master",
          "ref" => "refs/heads/master",
          "repository" => "accent/test-repo",
          "token" => "1234"
        },
        "project_id" => project.id,
        "user_id" => user.id
      }
    )
  end

  test "don’t broadcast event on other event", %{user: user, access_token: access_token, conn: conn, project: project} do
    params = %{
      "ref" => "refs/heads/master",
      "repository" => %{
        "full_name" => "accent/test-repo"
      }
    }

    data = %{default_ref: "master", repository: "accent/test-repo", token: "1234"}
    Repo.insert!(%Integration{project_id: project.id, user_id: user.id, service: "github", data: data})

    response =
      conn
      |> put_req_header("x-github-event", "pull_request_comment")
      |> post(hooks_github_path(conn, []) <> "?authorization=#{access_token.token}&project_id=#{project.id}", params)

    assert response.status == 501
  end

  test "don’t broadcast event on non existing integration", %{access_token: access_token, conn: conn, project: project} do
    params = %{
      "ref" => "refs/heads/master",
      "repository" => %{
        "full_name" => "accent/test-repo"
      }
    }

    response =
      conn
      |> put_req_header("x-github-event", "push")
      |> post(hooks_github_path(conn, []) <> "?authorization=#{access_token.token}&project_id=#{project.id}", params)

    assert response.status == 204
  end

  test "don’t broadcast event on non matching integration", %{
    user: user,
    access_token: access_token,
    conn: conn,
    project: project
  } do
    params = %{
      "ref" => "refs/heads/master",
      "repository" => %{
        "full_name" => "accent/test-repo"
      }
    }

    data = %{default_ref: "master", repository: "accent/other-repo", token: "1234"}
    Repo.insert!(%Integration{project_id: project.id, user_id: user.id, service: "github", data: data})

    response =
      conn
      |> put_req_header("x-github-event", "push")
      |> post(hooks_github_path(conn, []) <> "?authorization=#{access_token.token}&project_id=#{project.id}", params)

    assert response.status == 204
  end
end
