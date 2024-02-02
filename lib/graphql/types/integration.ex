defmodule Accent.GraphQL.Types.Integration do
  @moduledoc false
  use Absinthe.Schema.Notation

  enum :project_integration_service do
    value(:slack, as: "slack")
    value(:discord, as: "discord")
    value(:github, as: "github")
    value(:azure_storage_container, as: "azure_storage_container")
  end

  enum :project_integration_event do
    value(:sync, as: "sync")
    value(:new_conflicts, as: "new_conflicts")
    value(:complete_review, as: "complete_review")
    value(:create_collaborator, as: "create_collaborator")
    value(:create_comment, as: "create_comment")
  end

  interface :project_integration do
    field(:id, non_null(:id))
    field(:service, non_null(:project_integration_service))

    resolve_type(fn
      %{service: "discord"}, _ -> :project_integration_discord
      %{service: "slack"}, _ -> :project_integration_slack
      %{service: "github"}, _ -> :project_integration_github
      %{service: "azure_storage_container"}, _ -> :project_integration_azure_storage_container
    end)
  end

  object :project_integration_slack do
    field(:id, non_null(:id))
    field(:service, non_null(:project_integration_service))
    field(:events, non_null(list_of(non_null(:project_integration_event))))
    field(:data, non_null(:project_integration_slack_data))

    interfaces([:project_integration])
  end

  object :project_integration_discord do
    field(:id, non_null(:id))
    field(:service, non_null(:project_integration_service))
    field(:events, non_null(list_of(non_null(:project_integration_event))))
    field(:data, non_null(:project_integration_slack_data))

    interfaces([:project_integration])
  end

  object :project_integration_github do
    field(:id, non_null(:id))
    field(:service, non_null(:project_integration_service))
    field(:events, non_null(list_of(non_null(:project_integration_event))))
    field(:data, non_null(:project_integration_github_data))

    interfaces([:project_integration])
  end

  object :project_integration_azure_storage_container do
    field(:id, non_null(:id))
    field(:service, non_null(:project_integration_service))
    field(:last_executed_at, :datetime)
    field(:data, non_null(:project_integration_azure_data))

    interfaces([:project_integration])
  end

  object :project_integration_slack_data do
    field(:id, non_null(:id))
    field(:url, non_null(:string))
  end

  object :project_integration_github_data do
    field(:id, non_null(:id))
  end

  object :project_integration_azure_data do
    field(:id, non_null(:id))

    field(:sas_base_url, non_null(:string),
      resolve: fn data, _, _ ->
        uri = URI.parse(data.azure_storage_container_sas)
        uri = URI.to_string(%{uri | query: nil})
        {:ok, uri}
      end
    )
  end
end
