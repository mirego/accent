defmodule Accent.Hook.Consumers.Websocket do
  use Accent.Hook.EventConsumer, subscribe_to: [Accent.Hook.Producers.Websocket]

  alias Accent.{
    Endpoint,
    Hook
  }

  @channel "projects:"
  @supported_events ~w(sync create_collaborator create_comment)

  def handle_events(events, _from, state) do
    events
    |> Enum.filter(&filter_event/1)
    |> Enum.each(fn event ->
      event
      |> serialize_payload()
      |> merge_user()
      |> broadcast_event()
    end)

    {:noreply, [], state}
  end

  defp filter_event(%Hook.Context{event: event}), do: event in @supported_events

  defp broadcast_event(event) do
    Endpoint.broadcast(@channel <> event.project.id, event.event, event.payload)
  end

  defp merge_user(event = %Hook.Context{user: user, payload: payload}) do
    new_payload =
      Map.merge(payload, %{
        user: %{
          id: user.id,
          name: name_with_fallback(user)
        }
      })

    Map.put(event, :payload, new_payload)
  end

  defp name_with_fallback(%{fullname: nil, email: email}), do: email
  defp name_with_fallback(%{fullname: fullname}), do: fullname

  defp serialize_payload(event = %Hook.Context{event: "create_comment", payload: %{comment: comment}}) do
    Map.put(event, :payload, %{
      comment: %{
        text: comment.text,
        user: %{email: comment.user.email},
        translation: %{id: comment.translation.id, key: comment.translation.key}
      }
    })
  end

  defp serialize_payload(event = %Hook.Context{event: "create_collaborator", payload: %{collaborator: collaborator}}) do
    Map.put(event, :payload, %{
      collaborator: %{
        email: collaborator.email
      }
    })
  end

  defp serialize_payload(event = %Hook.Context{event: "sync", payload: %{document_path: document_path}}) do
    Map.put(event, :payload, %{
      document_path: document_path
    })
  end
end
