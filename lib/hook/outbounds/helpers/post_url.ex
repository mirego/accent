defmodule Accent.Hook.Outbounds.Helpers.PostURL do
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

  defp build_content(templates, %{event: "sync"} = context) do
    templates.sync(%{
      user: User.name_with_fallback(context.user),
      document_path: context.payload["document_path"],
      stats: context.payload["batch_operation_stats"]
    })
  end

  defp build_content(templates, %{event: "new_conflicts"} = context) do
    templates.new_conflicts(%{
      user: User.name_with_fallback(context.user),
      reviewed_count: context.payload["reviewed_count"],
      new_conflicts_count: context.payload["new_conflicts_count"],
      translations_count: context.payload["translations_count"]
    })
  end

  defp build_content(templates, %{event: "complete_review"} = context) do
    templates.complete_review(%{
      user: User.name_with_fallback(context.user),
      translations_count: context.payload["translations_count"]
    })
  end

  defp build_content(templates, %{event: "integration_execute_azure_storage_container"} = context) do
    templates.integration_execute_azure_storage_container(%{
      user: User.name_with_fallback(context.user),
      version_tag: context.payload["version_tag"],
      document_urls: context.payload["document_urls"]
    })
  end

  defp build_content(templates, %{event: "integration_execute_aws_s3"} = context) do
    templates.integration_execute_aws_s3(%{
      user: User.name_with_fallback(context.user),
      version_tag: context.payload["version_tag"],
      document_urls: context.payload["document_urls"]
    })
  end
end
