defmodule Accent.Hook.Outbounds.PostURL do
  require Logger

  import Ecto.Query, only: [where: 2]

  alias Accent.Repo

  def perform(service, build_body) do
    fn context = %{event: event, project: project} ->
      body = build_body.(context)
      integrations = filter_service_integration_events(project, event, service)
      urls = Enum.map(integrations, & &1.data.url)

      post_urls(urls, body, service)
    end
  end

  defp filter_service_integration_events(project, event, service) do
    project
    |> Ecto.assoc(:integrations)
    |> where(service: ^service)
    |> Repo.all()
    |> Enum.filter(&(event in &1.events))
  end

  defp post_urls(urls, body, service) do
    for url <- urls do
      Logger.metadata(hook_service: service, hook_url: url)
      start = System.monotonic_time()

      result = HTTPoison.post(url, Jason.encode!(body), [{"Content-Type", "application/json"}])
      stop = System.monotonic_time()
      diff = System.convert_time_unit(stop - start, :native, :microsecond)

      case result do
        {:ok, %{status_code: status}} ->
          Logger.info(["Responded ", to_string(status), " in ", formatted_diff(diff)])

        {:error, %{reason: reason}} ->
          Logger.info(["Responded ", inspect(reason), " in ", formatted_diff(diff)])

        _ ->
          Logger.info(["Unkown response in ", formatted_diff(diff)])
      end
    end

    :ok
  end

  defp formatted_diff(diff) when diff > 1000, do: [diff |> div(1000) |> Integer.to_string(), "ms"]
  defp formatted_diff(diff), do: [Integer.to_string(diff), "µs"]
end
