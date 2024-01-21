defmodule Accent.GraphQL.Resolvers.Integration do
  @moduledoc false
  import Accent.GraphQL.Response

  alias Accent.Integration
  alias Accent.IntegrationManager
  alias Accent.Plugs.GraphQLContext
  alias Accent.Project

  @typep integration_operation :: Accent.GraphQL.Response.t()

  @spec create(Project.t(), map(), GraphQLContext.t()) :: integration_operation
  def create(project, args, info) do
    args
    |> Map.put(:project_id, project.id)
    |> Map.put(:user_id, info.context[:conn].assigns[:current_user].id)
    |> IntegrationManager.create()
    |> build()
  end

  @spec update(Integration.t(), map(), GraphQLContext.t()) :: integration_operation
  def update(integration, args, _info) do
    integration
    |> IntegrationManager.update(args)
    |> build()
  end

  @spec execute(Integration.t(), map(), GraphQLContext.t()) :: integration_operation
  def execute(integration, args, info) do
    integration
    |> IntegrationManager.execute(info.context[:conn].assigns[:current_user], args)
    |> build()
  end

  @spec delete(Integration.t(), map(), GraphQLContext.t()) :: integration_operation
  def delete(integration, _args, _info) do
    integration
    |> IntegrationManager.delete()
    |> build()
  end
end
