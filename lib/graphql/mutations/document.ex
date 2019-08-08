defmodule Accent.GraphQL.Mutations.Document do
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Authorization

  object :document_mutations do
    field :delete_document, :mutated_document do
      arg(:id, non_null(:id))

      resolve(document_authorize(:delete_document, &Accent.GraphQL.Resolvers.Document.delete/3))
    end

    field :update_document, :mutated_document do
      arg(:id, non_null(:id))
      arg(:path, non_null(:string))

      resolve(document_authorize(:update_document, &Accent.GraphQL.Resolvers.Document.update/3))
    end
  end
end
