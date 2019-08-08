defmodule Accent.Hook.Consumers.PostURL do
  import Ecto.Query, only: [where: 2]

  @headers [{"Content-Type", "application/json"}]

  def handle_event(service, build_body) do
    fn context = %{event: event, project: project}, {:http_client, http_client} ->
      with integrations <- filter_service_integration_events(project, event, service),
           urls <- Enum.map(integrations, fn integration -> integration.data.url end),
           body <- build_body.(context) do
        post_urls(http_client, urls, body)
      end
    end
  end

  defp filter_service_integration_events(project, event, service) do
    project
    |> Ecto.assoc(:integrations)
    |> where(service: ^service)
    |> Accent.Repo.all()
    |> Enum.filter(fn integration -> event in integration.events end)
  end

  defp post_urls(http_client, urls, body) do
    for url <- urls do
      http_client.post(url, Jason.encode!(body), @headers)
    end

    :ok
  end
end
