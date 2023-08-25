defmodule Accent.GraphQL.Mutations.Collaborator do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Authorization

  alias Accent.GraphQL.Resolvers.Collaborator, as: CollaboratorResolver

  object :collaborator_mutations do
    field :create_collaborator, :mutated_collaborator do
      arg(:project_id, non_null(:id))
      arg(:role, non_null(:role))
      arg(:email, non_null(:string))

      resolve(project_authorize(:create_collaborator, &CollaboratorResolver.create/3, :project_id))
    end

    field :update_collaborator, :mutated_collaborator do
      arg(:id, non_null(:id))
      arg(:role, non_null(:role))

      resolve(collaborator_authorize(:update_collaborator, &CollaboratorResolver.update/3))
    end

    field :delete_collaborator, :mutated_collaborator do
      arg(:id, non_null(:id))

      resolve(collaborator_authorize(:delete_collaborator, &CollaboratorResolver.delete/3))
    end
  end
end
