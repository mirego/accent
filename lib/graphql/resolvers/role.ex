defmodule Accent.GraphQL.Resolvers.Role do
  alias Accent.{
    Role,
    Plugs.GraphQLContext
  }

  @spec list(any(), map(), GraphQLContext.t()) :: {:ok, list(Role.t())}
  def list(_, _, _), do: {:ok, Role.all()}
end
