defmodule Accent.GraphQL.Mutations.Operation do
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Authorization

  object :operation_mutations do
    field :rollback_operation, :mutated_operation do
      arg(:id, non_null(:id))

      resolve(operation_authorize(:rollback, &Accent.GraphQL.Resolvers.Operation.rollback/3))
    end
  end
end
