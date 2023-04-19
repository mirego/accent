defmodule Accent.GraphQL.Mutations.Prompt do
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Authorization
  alias Accent.GraphQL.Resolvers.Prompt, as: Resolver

  object :prompt_mutations do
    field :improve_text_with_prompt, :mutated_improved_text do
      arg(:id, non_null(:id))
      arg(:text, non_null(:string))

      resolve(prompt_authorize(:use_prompt_improve_text, &Resolver.improve_text/3))
    end

    field :delete_project_prompt, :mutated_prompt do
      arg(:id, non_null(:id))

      resolve(prompt_authorize(:delete_project_prompt, &Resolver.delete/3))
    end

    field :update_project_prompt, :mutated_prompt do
      arg(:id, non_null(:id))
      arg(:content, non_null(:string))
      arg(:quick_access, :string)
      arg(:name, :string)

      resolve(prompt_authorize(:update_project_prompt, &Resolver.update/3))
    end

    field :create_project_prompt, :mutated_prompt do
      arg(:project_id, non_null(:id))
      arg(:content, non_null(:string))
      arg(:quick_access, :string)
      arg(:name, :string)

      resolve(project_authorize(:create_project_prompt, &Resolver.create/3, :project_id))
    end

    field :save_project_prompt_config, :mutated_project do
      arg(:project_id, non_null(:id))
      arg(:provider, non_null(:string))
      arg(:config_key, :string)

      resolve(project_authorize(:save_project_prompt_config, &Resolver.save_config/3, :project_id))
    end

    field :delete_project_prompt_config, :mutated_project do
      arg(:project_id, non_null(:id))

      resolve(project_authorize(:delete_project_prompt_config, &Resolver.delete_config/3, :project_id))
    end
  end
end
