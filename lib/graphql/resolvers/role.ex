defmodule Accent.GraphQL.Resolvers.Role do
  alias Accent.{
    Plugs.GraphQLContext,
    Role
  }

  @spec list(any(), map(), GraphQLContext.t()) :: {:ok, list(Role.t())}
  def list(_, _, _), do: {:ok, Role.all()}
end
