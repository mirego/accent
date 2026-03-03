defmodule Accent.GraphQL.Resolvers.IntegrationExecution do
  @moduledoc false
  import Absinthe.Resolution.Helpers, only: [batch: 3]
  import Ecto.Query

  alias Accent.GraphQL.Paginated
  alias Accent.IntegrationExecution
  alias Accent.Repo

  def list_integration(integration, args, _resolution) do
    IntegrationExecution
    |> where(integration_id: ^integration.id)
    |> order_by(desc: :inserted_at)
    |> Paginated.paginate(args)
    |> Paginated.format()
    |> then(&{:ok, &1})
  end

  def last_by_version(version, _args, _resolution) do
    batch(
      {__MODULE__, :batch_last_by_version},
      version.id,
      fn results -> {:ok, Map.get(results, version.id, [])} end
    )
  end

  def batch_last_by_version(_, version_ids) do
    IntegrationExecution
    |> where([e], e.version_id in ^Enum.uniq(version_ids))
    |> distinct([e], [e.version_id, e.integration_id])
    |> order_by([e], [e.version_id, e.integration_id, desc: e.inserted_at])
    |> Repo.all()
    |> Enum.group_by(& &1.version_id)
  end
end
