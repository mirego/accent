defmodule Accent.GraphQL.Resolvers.Language do
  alias Accent.{
    Repo,
    Language,
    GraphQL.Paginated,
    Plugs.GraphQLContext
  }

  alias Accent.Scopes.Language, as: LanguageScope

  @page_size 10

  @spec list(any(), %{page: number(), query: String.t()}, GraphQLContext.t()) :: {:ok, Paginated.t(Language.t())}
  def list(_, args, _) do
    Language
    |> LanguageScope.from_search(args[:query])
    |> Repo.paginate(page: args[:page], page_size: @page_size)
    |> Paginated.format()
    |> (&{:ok, &1}).()
  end
end
