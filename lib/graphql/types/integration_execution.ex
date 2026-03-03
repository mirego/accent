defmodule Accent.GraphQL.Types.IntegrationExecution do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  enum :integration_execution_state do
    value(:success)
    value(:error)
  end

  object :integration_execution do
    field(:id, non_null(:id))
    field(:state, non_null(:integration_execution_state))
    field(:data, :json)
    field(:results, :json)
    field(:inserted_at, non_null(:datetime))
    field(:user, non_null(:user), resolve: dataloader(Accent.User))
    field(:version, :version, resolve: dataloader(Accent.Version))
    field(:integration, non_null(:project_integration), resolve: dataloader(Accent.Integration))
  end

  object :integration_executions do
    field(:meta, non_null(:pagination_meta))
    field(:entries, non_null(list_of(non_null(:integration_execution))))
  end
end
