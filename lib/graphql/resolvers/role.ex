defmodule Accent.GraphQL.Resolvers.Role do
  @moduledoc false
  alias Accent.Plugs.GraphQLContext
  alias Accent.Role

  @spec list(any(), map(), GraphQLContext.t()) :: {:ok, list(Role.t())}
  def list(_, _, _), do: {:ok, Role.all()}
end
