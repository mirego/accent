defmodule AccentTest.Hook.Outbounds.Websocket do
  use Accent.ChannelCase

  alias Accent.{
    Collaborator,
    Comment,
    Hook.Outbounds.Websocket,
    Language,
    Project,
    ProjectChannel,
    Repo,
    Revision,
    Translation,
    User,
    UserSocket
  }

  setup do
    language = %Language{name: "Test"} |> Repo.insert!()
    project = %Project{main_color: "#f00", name: "Test"} |> Repo.insert!()
    user = %User{fullname: "Test", email: "foo@test.com", permissions: %{project.id => "admin"}} |> Repo.insert!()
    revision = %Revision{project_id: project.id, language_id: language.id, master: true} |> Repo.insert!()
    translation = %Translation{key: "foo", corrected_text: "bar", proposed_text: "bar", revision_id: revision.id} |> Repo.insert!()

    {:ok, _, socket} =
      UserSocket
      |> socket("users:#{user.id}", %{user: user})
      |> subscribe_and_join(ProjectChannel, "projects:#{project.id}")

    [project: project, translation: translation, user: user, socket: socket]
  end

  test "comment", %{project: project, translation: translation, user: user} do
    commenter = %User{fullname: "Commenter", email: "comment@test.com"} |> Repo.insert!()
    comment = %Comment{translation_id: translation.id, user_id: commenter.id, text: "This is a comment"} |> Repo.insert!()
    comment = Repo.preload(comment, [:user, translation: [revision: :project]])

    payload = %{
      "text" => comment.text,
      "user" => %{"email" => comment.user.email},
      "translation" => %{"id" => comment.translation.id, "key" => comment.translation.key}
    }

    context = to_worker_args(%Accent.Hook.Context{project_id: project.id, user_id: user.id, event: "create_comment", payload: payload})

    _ = Websocket.perform(%Oban.Job{args: context})

    expected_payload = %{
      "payload" => %{
        "text" => comment.text,
        "user" => %{"email" => comment.user.email},
        "translation" => %{"id" => comment.translation.id, "key" => comment.translation.key}
      },
      "user" => %{
        "id" => user.id,
        "name" => user.fullname
      }
    }

    assert_broadcast "create_comment", ^expected_payload
  end

  test "sync", %{project: project, user: user} do
    payload = %{
      "document_path" => "foo.json"
    }

    context = to_worker_args(%Accent.Hook.Context{project_id: project.id, user_id: user.id, event: "sync", payload: payload})

    _ = Websocket.perform(%Oban.Job{args: context})

    expected_payload = %{
      "payload" => %{
        "document_path" => "foo.json"
      },
      "user" => %{
        "id" => user.id,
        "name" => user.fullname
      }
    }

    assert_broadcast "sync", ^expected_payload
  end

  test "collaborator", %{project: project, user: user} do
    collaborator = %Collaborator{email: "collab@test.com", project_id: project.id} |> Repo.insert!()

    payload = %{
      "collaborator" => %{
        "email" => collaborator.email
      }
    }

    context = to_worker_args(%Accent.Hook.Context{project_id: project.id, user_id: user.id, event: "create_collaborator", payload: payload})

    _ = Websocket.perform(%Oban.Job{args: context})

    expected_payload = %{
      "payload" => %{
        "collaborator" => %{
          "email" => collaborator.email
        }
      },
      "user" => %{
        "id" => user.id,
        "name" => user.fullname
      }
    }

    assert_broadcast "create_collaborator", ^expected_payload
  end
end
