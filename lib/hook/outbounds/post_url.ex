defmodule Accent.Hook.Outbounds.PostURL do
  import Ecto.Query, only: [where: 2]

  alias Accent.Repo

  def perform(service, build_body) do
    fn context = %{event: event, project: project} ->
      body = build_body.(context)
      integrations = filter_service_integration_events(project, event, service)
      urls = Enum.map(integrations, & &1.data.url)

      post_urls(urls, body)
    end
  end

  defp filter_service_integration_events(project, event, service) do
    project
    |> Ecto.assoc(:integrations)
    |> where(service: ^service)
    |> Repo.all()
    |> Enum.filter(&(event in &1.events))
  end

  defp post_urls(urls, body) do
    for url <- urls, do: HTTPoison.post(url, Jason.encode!(body), [{"Content-Type", "application/json"}])

    :ok
  end
end
