defmodule Accent.GraphQL.Resolvers.Operation do
  @moduledoc false
  alias Accent.Operation
  alias Accent.Plugs.GraphQLContext
  alias Accent.Repo
  alias Movement.Builders.Rollback, as: RollbackBuilder
  alias Movement.Persisters.Rollback, as: RollbackPersister

  @spec rollback(Operation.t(), any(), GraphQLContext.t()) :: {:ok, %{operation: boolean(), errors: [String.t()] | nil}}
  def rollback(operation, _, info) do
    operation = Repo.preload(operation, :batch_operation)

    %Movement.Context{}
    |> Movement.Context.assign(:operation, operation)
    |> Movement.Context.assign(:user_id, info.context[:conn].assigns[:current_user].id)
    |> RollbackBuilder.build()
    |> RollbackPersister.persist()
    |> case do
      {:ok, _} -> {:ok, %{operation: true, errors: nil}}
      {:error, _} -> {:ok, %{operation: false, errors: ["unprocessable_entity"]}}
    end
  end
end
