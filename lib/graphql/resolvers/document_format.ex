defmodule Accent.GraphQL.Resolvers.DocumentFormat do
  @moduledoc false
  alias Accent.DocumentFormat
  alias Accent.Plugs.GraphQLContext

  @spec list(any(), map(), GraphQLContext.t()) :: {:ok, list(DocumentFormat.t())}
  def list(_, _, _), do: {:ok, DocumentFormat.all()}
end
