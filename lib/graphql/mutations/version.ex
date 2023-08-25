defmodule Accent.GraphQL.Mutations.Version do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Authorization

  object :version_mutations do
    field :create_version, :mutated_version do
      arg(:project_id, non_null(:id))
      arg(:name, non_null(:string))
      arg(:tag, non_null(:string))

      resolve(project_authorize(:create_version, &Accent.GraphQL.Resolvers.Version.create/3, :project_id))
    end

    field :update_version, :mutated_version do
      arg(:id, non_null(:id))
      arg(:name, non_null(:string))
      arg(:tag, non_null(:string))

      resolve(version_authorize(:update_version, &Accent.GraphQL.Resolvers.Version.update/3))
    end
  end
end
