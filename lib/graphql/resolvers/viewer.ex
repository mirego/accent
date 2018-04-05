defmodule Accent.GraphQL.Resolvers.Viewer do
  alias Accent.{
    User,
    Plugs.GraphQLContext
  }

  @spec show(nil, map(), GraphQLContext.t()) :: {:ok, User.t() | nil}
  def show(_, _, %{context: context}) do
    {:ok, context[:conn].assigns[:current_user]}
  end
end
