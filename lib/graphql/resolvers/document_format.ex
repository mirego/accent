defmodule Accent.GraphQL.Resolvers.DocumentFormat do
  alias Accent.{
    DocumentFormat,
    Plugs.GraphQLContext
  }

  @spec list(any(), map(), GraphQLContext.t()) :: {:ok, list(DocumentFormat.t())}
  def list(_, _, _), do: {:ok, DocumentFormat.all()}
end
