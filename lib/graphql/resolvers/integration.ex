defmodule Accent.GraphQL.Resolvers.Integration do
  @moduledoc false
  import Accent.GraphQL.Response

  alias Accent.Integration
  alias Accent.IntegrationManager
  alias Accent.Plugs.GraphQLContext
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Scopes.Integration, as: IntegrationScope

  require Ecto.Query

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

  @spec list_project(Project.t(), map(), GraphQLContext.t()) :: {:ok, [Integration.t()]}
  def list_project(project, _args, _) do
    Integration
    |> IntegrationScope.from_project(project.id)
    |> Ecto.Query.order_by(desc: :inserted_at)
    |> Repo.all()
    |> then(&{:ok, &1})
  end
end
