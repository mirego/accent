defmodule Accent.Hook.Consumers.Websocket do
  use Accent.Hook.EventConsumer, subscribe_to: [Accent.Hook.Producers.Websocket]

  alias Accent.User
  alias Accent.Hook

  @channel "projects:"
  @supported_events ~w(sync create_collaborator create_comment)

  def handle_events(events, _from, state = {:endpoint, endpoint}) do
    events
    |> Enum.filter(&filter_event/1)
    |> Enum.each(fn event ->
      event
      |> serialize_payload()
      |> merge_user()
      |> broadcast_event(endpoint)
    end)

    {:noreply, [], state}
  end

  defp filter_event(%Hook.Context{event: event}), do: event in @supported_events

  defp broadcast_event(event, endpoint) do
    endpoint.broadcast(@channel <> event.project.id, event.event, event.payload)
  end

  defp merge_user(event = %Hook.Context{user: user, payload: payload}) do
    new_payload =
      payload
      |> Map.merge(%{
        user: %{
          id: user.id,
          name: User.name_with_fallback(user)
        }
      })

    %{event | payload: new_payload}
  end

  defp serialize_payload(event = %Hook.Context{event: "create_comment", payload: %{comment: comment}}) do
    %{
      event
      | payload: %{
          comment: %{
            text: comment.text,
            user: %{email: comment.user.email},
            translation: %{id: comment.translation.id, key: comment.translation.key}
          }
        }
    }
  end

  defp serialize_payload(event = %Hook.Context{event: "create_collaborator", payload: %{collaborator: collaborator}}) do
    %{
      event
      | payload: %{
          collaborator: %{
            email: collaborator.email
          }
        }
    }
  end

  defp serialize_payload(event = %Hook.Context{event: "sync", payload: %{document_path: document_path}}) do
    %{
      event
      | payload: %{
          document_path: document_path
        }
    }
  end
end
