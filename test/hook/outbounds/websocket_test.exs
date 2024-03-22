defmodule AccentTest.Hook.Outbounds.Websocket do
  @moduledoc false
  use Accent.ChannelCase

  alias Accent.Collaborator
  alias Accent.Comment
  alias Accent.Hook.Outbounds.Websocket
  alias Accent.Language
  alias Accent.Project
  alias Accent.ProjectChannel
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User
  alias Accent.UserSocket

  setup do
    language = Factory.insert(Language, name: "Test")
    project = Factory.insert(Project)
    user = Factory.insert(User, fullname: "Test", email: "foo@test.com", permissions: %{project.id => "admin"})
    revision = Factory.insert(Revision, project_id: project.id, language_id: language.id, master: true)

    translation =
      Factory.insert(Translation, key: "foo", corrected_text: "bar", proposed_text: "bar", revision_id: revision.id)

    {:ok, _, socket} =
      UserSocket
      |> socket("users:#{user.id}", %{user: user})
      |> subscribe_and_join(ProjectChannel, "projects:#{project.id}")

    [project: project, translation: translation, user: user, socket: socket]
  end

  test "comment", %{project: project, translation: translation, user: user} do
    commenter = Factory.insert(User, fullname: "Commenter", email: "comment@test.com")
    comment = Factory.insert(Comment, translation_id: translation.id, user_id: commenter.id, text: "This is a comment")
    comment = Repo.preload(comment, [:user, translation: [revision: :project]])

    payload = %{
      "text" => comment.text,
      "user" => %{"email" => comment.user.email},
      "translation" => %{"id" => comment.translation.id, "key" => comment.translation.key}
    }

    context =
      to_worker_args(%Accent.Hook.Context{
        project_id: project.id,
        user_id: user.id,
        event: "create_comment",
        payload: payload
      })

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

    context =
      to_worker_args(%Accent.Hook.Context{project_id: project.id, user_id: user.id, event: "sync", payload: payload})

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
    collaborator = Factory.insert(Collaborator, email: "collab@test.com", project_id: project.id)

    payload = %{
      "collaborator" => %{
        "email" => collaborator.email
      }
    }

    context =
      to_worker_args(%Accent.Hook.Context{
        project_id: project.id,
        user_id: user.id,
        event: "create_collaborator",
        payload: payload
      })

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
