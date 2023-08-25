defmodule Accent.GraphQL.Types.User do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Fields

  alias Accent.User

  object :user do
    field(:id, non_null(:id))
    field(:is_bot, non_null(:boolean), resolve: field_alias(:bot))
    field(:email, :string)
    field(:picture_url, :string)

    field :fullname, non_null(:string) do
      resolve(fn user, _, _ -> {:ok, User.name_with_fallback(user)} end)
    end
  end
end
