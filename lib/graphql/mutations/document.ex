defmodule Accent.GraphQL.Mutations.Document do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Authorization

  alias Accent.GraphQL.Resolvers.Document

  object :document_mutations do
    field :delete_document, :mutated_document do
      arg(:id, non_null(:id))

      resolve(document_authorize(:delete_document, &Document.delete/3))
    end

    field :update_document, :mutated_document do
      arg(:id, non_null(:id))
      arg(:path, non_null(:string))

      resolve(document_authorize(:update_document, &Document.update/3))
    end
  end
end
