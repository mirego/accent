defmodule Accent.GraphQL.Resolvers.Language do
  alias Accent.{
    GraphQL.Paginated,
    Language,
    Plugs.GraphQLContext
  }

  alias Accent.Scopes.Language, as: LanguageScope

  @spec list(any(), %{page: number(), query: String.t()}, GraphQLContext.t()) :: {:ok, Paginated.t(Language.t())}
  def list(_, args, _) do
    Language
    |> LanguageScope.from_search(args[:query])
    |> Paginated.paginate(args)
    |> Paginated.format()
    |> (&{:ok, &1}).()
  end
end
