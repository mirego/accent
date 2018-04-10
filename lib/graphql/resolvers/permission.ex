defmodule Accent.GraphQL.Resolvers.Permission do
  alias Accent.{
    User,
    Project,
    Plugs.GraphQLContext
  }

  @spec list_viewer(User.t(), any(), GraphQLContext.t()) :: {:ok, [atom()]}
  def list_viewer(current_user, _, _) do
    permissions =
      current_user
      |> Map.get(:email)
      |> Accent.EmailAbilities.actions_for()

    {:ok, permissions}
  end

  @spec list_project(Project.t(), any(), GraphQLContext.t()) :: {:ok, [atom()]}
  def list_project(project, _, %{context: context}) do
    permissions =
      context[:conn].assigns[:current_user].permissions
      |> Map.get(project.id)
      |> Accent.RoleAbilities.actions_for()

    {:ok, permissions}
  end
end
