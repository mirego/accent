defmodule Accent.GraphQL.Resolvers.Permission do
  alias Accent.{
    Project,
    Plugs.GraphQLContext
  }

  @spec list_project(Project.t(), any(), GraphQLContext.t()) :: {:ok, [atom()]}
  def list_project(project, _, %{context: context}) do
    permissions =
      context[:conn].assigns[:current_user].permissions
      |> Map.get(project.id)
      |> Accent.RoleAbilities.actions_for()

    {:ok, permissions}
  end
end
