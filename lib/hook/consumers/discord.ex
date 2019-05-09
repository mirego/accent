defmodule Accent.Hook.Consumers.Discord do
  use Accent.Hook.EventConsumer, subscribe_to: [Accent.Hook.Producers.Discord]

  import Ecto.Query

  alias Accent.{
    Hook.Context,
    Repo
  }

  @headers [{"Content-Type", "application/json"}]
  @service "discord"
  @supported_events ~w(sync)

  def handle_events(events, _from, state) do
    events
    |> Enum.filter(&filter_event/1)
    |> Enum.each(fn event ->
      handle_event(event, state)
    end)

    {:noreply, [], state}
  end

  defp filter_event(%Context{event: event}), do: event in @supported_events

  defp handle_event(context = %Context{event: event, project: project}, {:http_client, http_client}) do
    with integrations <- filter_service_integration_events(project, event, @service),
         urls <- Enum.map(integrations, fn integration -> integration.data.url end),
         body <- build_body(context) do
      post_urls(http_client, urls, body)
    end
  end

  defp build_body(%Context{event: "sync", user: user, payload: %{document_path: document_path, batch_operation_stats: stats}}) do
    %{
      content: """
      **#{user.fullname}** just synced a file: *#{document_path}*

      **Stats:**
      #{build_stats(stats)}
      """
    }
  end

  defp build_stats(stats) do
    Enum.reduce(stats, "", fn %{action: action, count: count}, acc ->
      "#{acc}#{action}: *#{count}*\n"
    end)
  end

  defp filter_service_integration_events(project, event, service) do
    project
    |> Ecto.assoc(:integrations)
    |> where(service: ^service)
    |> Repo.all()
    |> Enum.filter(fn integration -> event in integration.events end)
  end

  defp post_urls(http_client, urls, body) do
    for url <- urls do
      http_client.post(url, Jason.encode!(body), @headers)
    end

    :ok
  end
end
