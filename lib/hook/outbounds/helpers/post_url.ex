defmodule Accent.Hook.Outbounds.Helpers.PostURL do
  @moduledoc false
  import Ecto.Changeset, only: [change: 2]
  import Ecto.Query, only: [where: 2]

  alias Accent.IntegrationExecution
  alias Accent.Repo
  alias Accent.User

  require Logger

  def perform(service, context, options) do
    integrations = fetch_service_integrations(context.project, context.event, service)

    if Enum.any?(integrations) do
      templates = options[:templates]
      http_body = options[:http_body]
      content = build_content(templates, context)
      body = http_body.(content)

      post_integrations(integrations, body, service, context)
    else
      :ok
    end
  end

  defp fetch_service_integrations(project, event, service) do
    project
    |> Ecto.assoc(:integrations)
    |> where(service: ^service)
    |> Repo.all()
    |> Enum.filter(&(event in &1.events))
  end

  defp post_integrations(integrations, body, service, context) do
    for integration <- integrations do
      url = integration.data.url
      Logger.metadata(hook_service: service, hook_url: url)
      start = System.monotonic_time()

      result = HTTPoison.post(url, Jason.encode!(body), [{"Content-Type", "application/json"}])
      stop = System.monotonic_time()
      diff = System.convert_time_unit(stop - start, :native, :microsecond)

      {state, results} = execution_from_result(result, diff)

      Logger.info(["Responded ", results_log(result), " in ", formatted_diff(diff)])

      execution =
        Repo.insert!(%IntegrationExecution{
          integration_id: integration.id,
          user_id: context.user_id,
          state: state,
          data: %{"event" => context.event, "service" => service},
          results: results
        })

      integration
      |> change(%{last_integration_execution_id: execution.id})
      |> Repo.update!()
    end

    :ok
  end

  defp execution_from_result({:ok, %{status_code: status, body: response_body}}, diff) do
    state = if status in 200..299, do: :success, else: :error

    {state, %{"status" => status, "body" => String.slice(to_string(response_body), 0, 1000), "duration_µs" => diff}}
  end

  defp execution_from_result({:error, %{reason: reason}}, diff) do
    {:error, %{"error" => to_string(reason), "duration_µs" => diff}}
  end

  defp execution_from_result(_, diff) do
    {:error, %{"error" => "unknown_response", "duration_µs" => diff}}
  end

  defp results_log({:ok, %{status_code: status}}), do: to_string(status)
  defp results_log({:error, %{reason: reason}}), do: inspect(reason)
  defp results_log(_), do: "unknown"

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
