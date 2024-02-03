defmodule Accent.GraphQL.Mutations.Revision do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Authorization

  alias Accent.GraphQL.Resolvers.Revision, as: RevisionResolver

  object :revision_mutations do
    field :create_revision, :mutated_revision do
      arg(:project_id, non_null(:id))
      arg(:language_id, non_null(:id))
      arg(:default_null, :boolean, default_value: false)
      arg(:machine_translations_enabled, :boolean, default_value: false)

      resolve(project_authorize(:create_slave, &RevisionResolver.create/3, :project_id))
    end

    field :delete_revision, :mutated_revision do
      arg(:id, non_null(:id))

      resolve(revision_authorize(:delete_slave, &RevisionResolver.delete/3))
    end

    field :update_revision, :mutated_revision do
      arg(:id, non_null(:id))
      arg(:name, :string)
      arg(:slug, :string)

      resolve(revision_authorize(:update_slave, &RevisionResolver.update/3))
    end

    field :promote_revision_master, :mutated_revision do
      arg(:id, non_null(:id))

      resolve(revision_authorize(:promote_slave, &RevisionResolver.promote_master/3))
    end

    field :correct_all_revision, :mutated_revision do
      arg(:id, non_null(:id))

      resolve(revision_authorize(:correct_all_revision, &RevisionResolver.correct_all/3))
    end

    field :uncorrect_all_revision, :mutated_revision do
      arg(:id, non_null(:id))

      resolve(revision_authorize(:uncorrect_all_revision, &RevisionResolver.uncorrect_all/3))
    end
  end
end
