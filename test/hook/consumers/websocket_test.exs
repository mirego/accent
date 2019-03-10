defmodule MockEndpoint do
  def broadcast(channel, event, payload) do
    send(self(), {:delivered_socket, channel, event, payload})
  end
end

defmodule AccentTest.Hook.Consumers.Websocket do
  use Accent.RepoCase

  alias Accent.{
    Collaborator,
    Comment,
    Hook.Consumers.Websocket,
    Language,
    Project,
    Repo,
    Revision,
    Translation,
    User
  }

  setup do
    language = %Language{name: "Test"} |> Repo.insert!()
    project = %Project{main_color: "#f00", name: "Test"} |> Repo.insert!()
    user = %User{fullname: "Test", email: "foo@test.com"} |> Repo.insert!()
    revision = %Revision{project_id: project.id, language_id: language.id, master: true} |> Repo.insert!()
    translation = %Translation{key: "foo", corrected_text: "bar", proposed_text: "bar", revision_id: revision.id} |> Repo.insert!()

    [project: project, translation: translation, user: user]
  end

  test "comment", %{project: project, translation: translation, user: user} do
    commenter = %User{fullname: "Commenter", email: "comment@test.com"} |> Repo.insert!()
    comment = %Comment{translation_id: translation.id, user_id: commenter.id, text: "This is a comment"} |> Repo.insert!()
    comment = Repo.preload(comment, [:user, translation: [revision: :project]])

    event = %Accent.Hook.Context{project: project, user: user, event: "create_comment", payload: %{comment: comment}}

    {:noreply, _, _} = Websocket.handle_events([event], nil, {:endpoint, MockEndpoint})

    channel = "projects:#{project.id}"

    payload = %{
      comment: %{
        text: comment.text,
        user: %{email: comment.user.email},
        translation: %{id: comment.translation.id, key: comment.translation.key}
      },
      user: %{
        id: user.id,
        name: user.fullname
      }
    }

    assert_receive {:delivered_socket, ^channel, "create_comment", ^payload}
  end

  test "sync", %{project: project, user: user} do
    event = %Accent.Hook.Context{project: project, user: user, event: "sync", payload: %{document_path: "foo.json"}}

    {:noreply, _, _} = Websocket.handle_events([event], nil, {:endpoint, MockEndpoint})

    channel = "projects:#{project.id}"

    payload = %{
      document_path: "foo.json",
      user: %{
        id: user.id,
        name: user.fullname
      }
    }

    assert_receive {:delivered_socket, ^channel, "sync", ^payload}
  end

  test "collaborator", %{project: project, user: user} do
    collaborator = %Collaborator{email: "collab@test.com", project_id: project.id} |> Repo.insert!()
    event = %Accent.Hook.Context{project: project, user: user, event: "create_collaborator", payload: %{collaborator: collaborator}}

    {:noreply, _, _} = Websocket.handle_events([event], nil, {:endpoint, MockEndpoint})

    channel = "projects:#{project.id}"

    payload = %{
      collaborator: %{
        email: collaborator.email
      },
      user: %{
        id: user.id,
        name: user.fullname
      }
    }

    assert_receive {:delivered_socket, ^channel, "create_collaborator", ^payload}
  end

  test "unknown event", %{project: project, translation: translation, user: user} do
    commenter = %User{fullname: "Commenter", email: "comment@test.com"} |> Repo.insert!()
    comment = %Comment{translation_id: translation.id, user_id: commenter.id, text: "This is a comment"} |> Repo.insert!()
    comment = Repo.preload(comment, [:user, translation: [revision: :project]])

    event = %Accent.Hook.Context{project: project, user: user, event: "update_comment", payload: %{comment: comment}}

    {:noreply, _, _} = Websocket.handle_events([event], nil, {:endpoint, MockEndpoint})

    channel = "projects:#{project.id}"

    payload = %{
      comment: %{
        text: comment.text,
        user: %{email: comment.user.email},
        translation: %{id: comment.translation.id, key: comment.translation.key}
      },
      user: %{
        id: user.id,
        name: user.fullname
      }
    }

    refute_receive {:delivered_socket, ^channel, "update_comment", ^payload}
  end
end
