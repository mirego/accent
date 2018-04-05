defmodule Accent.GraphQL.Types.Integration do
  use Absinthe.Schema.Notation

  enum :integration_service do
    value(:slack, as: "slack")
  end

  enum :integration_event do
    value(:sync, as: "sync")
    value(:merge, as: "merge")
  end

  object :integration do
    field(:id, non_null(:id))
    field(:service, non_null(:integration_service))
    field(:events, non_null(list_of(non_null(:integration_event))))
    field(:data, non_null(:integration_data))
  end

  object :integration_data do
    field(:id, non_null(:id))
    field(:url, non_null(:string))
  end
end
