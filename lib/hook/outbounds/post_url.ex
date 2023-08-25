defmodule Accent.Hook.Outbounds.PostURL do
  @moduledoc false
  import Ecto.Query, only: [where: 2]

  alias Accent.Repo
  alias Accent.User

  require Logger

  def perform(service, context, options) do
    urls = fetch_service_integration_urls(context.project, context.event, service)

    if Enum.any?(urls) do
      templates = options[:templates]
      http_body = options[:http_body]
      content = build_content(templates, context)
      body = http_body.(content)

      post_urls(urls, body, service)
    else
      :ok
    end
  end

  defp fetch_service_integration_urls(project, event, service) do
    project
    |> Ecto.assoc(:integrations)
    |> where(service: ^service)
    |> Repo.all()
    |> Enum.filter(&(event in &1.events))
    |> Enum.map(& &1.data.url)
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

  defp build_content(templates, %{event: "sync", user: user, payload: payload}) do
    templates.sync(%{
      user: User.name_with_fallback(user),
      document_path: payload["document_path"],
      stats: payload["batch_operation_stats"]
    })
  end

  defp build_content(templates, %{event: "new_conflicts", user: user, payload: payload}) do
    templates.new_conflicts(%{
      user: User.name_with_fallback(user),
      reviewed_count: payload["reviewed_count"],
      new_conflicts_count: payload["new_conflicts_count"],
      translations_count: payload["translations_count"]
    })
  end

  defp build_content(templates, %{event: "complete_review", user: user, payload: payload}) do
    templates.complete_review(%{
      user: User.name_with_fallback(user),
      translations_count: payload["translations_count"]
    })
  end
end
