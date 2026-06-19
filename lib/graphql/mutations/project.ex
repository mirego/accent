defmodule Accent.GraphQL.Mutations.Project do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Authorization

  alias Accent.GraphQL.Resolvers.Project, as: ProjectResolver

  object :project_mutations do
    field :create_project, :mutated_project do
      arg(:name, non_null(:string))
      arg(:main_color, non_null(:string))
      arg(:logo, :string)
      arg(:language_id, non_null(:id))

      resolve(viewer_authorize(:create_project, &ProjectResolver.create/3))
    end

    field :update_project, :mutated_project do
      arg(:id, non_null(:id))
      arg(:name, non_null(:string))
      arg(:main_color, non_null(:string))
      arg(:logo, :string)
      arg(:is_file_operations_locked, :boolean)

      resolve(project_authorize(:update_project, &ProjectResolver.update/3))
    end

    field :delete_project, :mutated_project do
      arg(:id, non_null(:id))

      resolve(project_authorize(:delete_project, &ProjectResolver.delete/3))
    end

    field :fix_lint_translations, :mutated_project do
      arg(:id, non_null(:id))
      arg(:revision_id, :id, default_value: nil)
      arg(:query, :string)
      arg(:check_ids, list_of(non_null(:id)), default_value: [])
      arg(:check, :lint_check, default_value: nil)

      resolve(project_authorize(:fix_lint_translations, &ProjectResolver.fix_lint_translations/3))
    end
  end
end
