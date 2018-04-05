defmodule Accent.GraphQL.Resolvers.Integration do
  alias Accent.{
    Project,
    Integration,
    IntegrationManager,
    Plugs.GraphQLContext
  }

  @typep integration_operation :: {:ok, %{integration: Integration.t() | nil, errors: [String.t()] | nil}}

  @spec create(Project.t(), map(), GraphQLContext.t()) :: integration_operation
  def create(project, args, info) do
    args =
      args
      |> Map.put(:project_id, project.id)
      |> Map.put(:user_id, info.context[:conn].assigns[:current_user].id)

    resolve(IntegrationManager.create(args))
  end

  @spec update(Integration.t(), map(), GraphQLContext.t()) :: integration_operation
  def update(integration, args, _info) do
    resolve(IntegrationManager.update(integration, args))
  end

  @spec delete(Integration.t(), map(), GraphQLContext.t()) :: integration_operation
  def delete(integration, _args, _info) do
    resolve(IntegrationManager.delete(integration))
  end

  defp resolve(result) do
    case result do
      {:ok, integration} ->
        {:ok, %{integration: integration, errors: nil}}

      {:error, _reason} ->
        {:ok, %{integration: nil, errors: ["unprocessable_entity"]}}
    end
  end
end
