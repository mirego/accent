defmodule Accent.GraphQL.Mutations.APIToken do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Authorization

  alias Accent.GraphQL.Resolvers.APIToken, as: APITokenResolver

  object :api_token_mutations do
    field :create_api_token, :mutated_api_token do
      arg(:project_id, non_null(:id))
      arg(:name, non_null(:string))
      arg(:picture_url, :string)
      arg(:permissions, list_of(non_null(:string)))

      resolve(project_authorize(:create_project_api_token, &APITokenResolver.create/3, :project_id))
    end

    field :revoke_api_token, :mutated_api_token do
      arg(:id, non_null(:id))

      resolve(api_token_authorize(:revoke_project_api_token, &APITokenResolver.revoke/3))
    end
  end
end
