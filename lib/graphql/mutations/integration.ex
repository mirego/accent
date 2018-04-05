defmodule Accent.GraphQL.Mutations.Integration do
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Authorization

  alias Accent.GraphQL.Resolvers.Integration, as: IntegrationResolver

  input_object :integration_data_input do
    field(:id, :id)
    field(:url, non_null(:string))
  end

  object :integration_mutations do
    field :create_integration, :mutated_integration do
      arg(:project_id, non_null(:id))
      arg(:service, non_null(:integration_service))
      arg(:events, non_null(list_of(non_null(:integration_event))))
      arg(:data, non_null(:integration_data_input))

      resolve(project_authorize(:create_integration, &IntegrationResolver.create/3, :project_id))
    end

    field :update_integration, :mutated_integration do
      arg(:id, non_null(:id))
      arg(:service, :integration_service)
      arg(:events, non_null(list_of(non_null(:integration_event))))
      arg(:data, non_null(:integration_data_input))

      resolve(integration_authorize(:update_integration, &IntegrationResolver.update/3))
    end

    field :delete_integration, :mutated_integration do
      arg(:id, non_null(:id))

      resolve(integration_authorize(:delete_integration, &IntegrationResolver.delete/3))
    end
  end
end
