defmodule Accent.GraphQL.Resolvers.Viewer do
  @moduledoc false
  alias Accent.AccessToken
  alias Accent.Plugs.GraphQLContext
  alias Accent.Repo
  alias Accent.User

  @spec show(nil, map(), GraphQLContext.t()) :: {:ok, User.t() | nil}
  def show(_, _, %{context: context}) do
    {:ok, context[:conn].assigns[:current_user]}
  end

  @spec show_access_token(User.t(), map(), GraphQLContext.t()) :: {:ok, AccessToken.t() | nil}
  def show_access_token(user, _, _) do
    token = Repo.one(Ecto.assoc(user, :global_access_token))
    {:ok, token && token.token}
  end
end
