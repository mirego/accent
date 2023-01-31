defmodule Accent.GraphQL.Resolvers.APIToken do
  alias Accent.{
    AccessToken,
    APITokenManager,
    Plugs.GraphQLContext,
    Project
  }

  @spec create(Project.t(), any(), GraphQLContext.t()) :: {:ok, AccessToken.t() | nil}
  def create(project, args, info) do
    case APITokenManager.create(project, info.context[:conn].assigns[:current_user], args) do
      {:ok, %{access_token: api_token}} ->
        {:ok, %{api_token: api_token, errors: nil}}

      {:error, _reason, _, _} ->
        {:ok, %{access_token: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec revoke(Project.t(), any(), GraphQLContext.t()) :: {:ok, AccessToken.t() | nil}
  def revoke(access_token, _args, _) do
    APITokenManager.revoke(access_token)
    {:ok, true}
  end

  @spec list_project(Project.t(), any(), GraphQLContext.t()) :: {:ok, AccessToken.t() | nil}
  def list_project(project, _, _) do
    {:ok, APITokenManager.list(project)}
  end
end
