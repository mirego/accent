defmodule Accent.GraphQL.Types.Version do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  object :version do
    field(:id, non_null(:id))
    field(:name, non_null(:string))
    field(:tag, non_null(:string))
    field(:project, :project, resolve: dataloader(Accent.Project))
    field(:user, :user, resolve: dataloader(Accent.User))
    field(:copy_on_update_translation, non_null(:boolean))
    field(:inserted_at, non_null(:datetime))

    field(:last_integration_executions, non_null(list_of(non_null(:integration_execution))),
      resolve: &Accent.GraphQL.Resolvers.IntegrationExecution.last_by_version/3
    )
  end

  object :versions do
    field(:meta, :pagination_meta)
    field(:entries, list_of(:version))
  end
end
