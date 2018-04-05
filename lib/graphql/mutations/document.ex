defmodule Accent.GraphQL.Mutations.Document do
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Authorization

  object :document_mutations do
    field :delete_document, :mutated_document do
      arg(:id, non_null(:id))

      resolve(document_authorize(:delete_document, &Accent.GraphQL.Resolvers.Document.delete/3))
    end
  end
end
