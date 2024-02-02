defmodule Accent.GraphQL.Mutations.Integration do
  @moduledoc false
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload
  import Accent.GraphQL.Helpers.Authorization

  alias Accent.GraphQL.Resolvers.Integration, as: IntegrationResolver

  enum :project_integration_execute_azure_storage_container_target_version do
    value(:specific)
    value(:latest)
  end

  input_object :project_integration_execute_azure_storage_container_input do
    field(:target_version, :project_integration_execute_azure_storage_container_target_version)
    field(:tag, :string)
  end

  input_object :project_integration_data_input do
    field(:id, :id)
    field(:url, :string)
    field(:azure_storage_container_sas, :string)
  end

  payload_object(:project_integration_payload, :project_integration)

  object :integration_mutations do
    field :create_project_integration, :project_integration_payload do
      arg(:project_id, non_null(:id))
      arg(:service, non_null(:project_integration_service))
      arg(:events, list_of(non_null(:project_integration_event)))
      arg(:data, non_null(:project_integration_data_input))

      resolve(project_authorize(:create_project_integration, &IntegrationResolver.create/3, :project_id))
      middleware(&build_payload/2)
    end

    field :execute_project_integration, :project_integration_payload do
      arg(:id, non_null(:id))
      arg(:azure_storage_container, :project_integration_execute_azure_storage_container_input)

      resolve(integration_authorize(:execute_project_integration, &IntegrationResolver.execute/3))
      middleware(&build_payload/2)
    end

    field :update_project_integration, :project_integration_payload do
      arg(:id, non_null(:id))
      arg(:service, non_null(:project_integration_service))
      arg(:events, list_of(non_null(:project_integration_event)))
      arg(:data, non_null(:project_integration_data_input))

      resolve(integration_authorize(:update_project_integration, &IntegrationResolver.update/3))
      middleware(&build_payload/2)
    end

    field :delete_project_integration, :project_integration_payload do
      arg(:id, non_null(:id))

      resolve(integration_authorize(:delete_project_integration, &IntegrationResolver.delete/3))
      middleware(&build_payload/2)
    end
  end
end
