defmodule Accent.GraphQL.Mutations.MachineTranslationsConfig do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Authorization

  alias Accent.GraphQL.Resolvers.MachineTranslationsConfig, as: Resolver

  object :machine_translations_config_mutations do
    field :save_project_machine_translations_config, :mutated_project do
      arg(:project_id, non_null(:id))
      arg(:provider, non_null(:string))
      arg(:use_platform, non_null(:boolean))
      arg(:enabled_actions, non_null(list_of(non_null(:string))))
      arg(:config_key, :string)

      resolve(project_authorize(:save_project_machine_translations_config, &Resolver.save/3, :project_id))
    end

    field :delete_project_machine_translations_config, :mutated_project do
      arg(:project_id, non_null(:id))

      resolve(project_authorize(:delete_project_machine_translations_config, &Resolver.delete/3, :project_id))
    end
  end
end
