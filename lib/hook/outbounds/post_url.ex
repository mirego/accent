defmodule Accent.Hook.Outbounds.PostURL do
  @moduledoc false
  import Ecto.Query, only: [where: 2]

  alias Accent.Repo
  alias Accent.User

  require Logger

  def perform(service, context, templates) do
    urls = fetch_service_integration_urls(context.project, context.event, service)
    body = build_body(templates, context)

    post_urls(urls, body, service)
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

  defp build_body(templates, %{
         event: "sync",
         user: user,
         payload: %{"document_path" => document_path, "batch_operation_stats" => stats}
       }) do
    assigns = %{
      user: User.name_with_fallback(user),
      document_path: document_path,
      stats: stats
    }

    %{text: templates.sync(assigns)}
  end

  defp build_body(templates, %{event: "new_conflicts", user: user, payload: payload}) do
    assigns = %{
      user: User.name_with_fallback(user),
      reviewed_count: payload["reviewed_count"],
      new_conflicts_count: payload["new_conflicts_count"],
      translations_count: payload["translations_count"]
    }

    %{text: templates.new_conflicts(assigns)}
  end

  defp build_body(templates, %{event: "complete_review", user: user, payload: payload}) do
    assigns = %{
      user: User.name_with_fallback(user),
      translations_count: payload["translations_count"]
    }

    %{text: templates.complete_review(assigns)}
  end
end
