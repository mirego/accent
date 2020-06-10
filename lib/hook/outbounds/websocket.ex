defmodule Accent.Hook.Outbounds.Websocket do
  use Oban.Worker, queue: :hook

  @impl Oban.Worker
  def perform(context, _job) do
    context
    |> Accent.Hook.Context.from_worker()
    |> merge_user()
    |> broadcast_event()
  end

  defp broadcast_event(event) do
    Accent.Endpoint.broadcast("projects:" <> event.project.id, event.event, event.payload)
  end

  defp merge_user(event = %{user: user, payload: payload}) do
    %{
      event
      | payload: %{
          "payload" => payload,
          "user" => %{
            "id" => user.id,
            "name" => Accent.User.name_with_fallback(user)
          }
        }
    }
  end
end
