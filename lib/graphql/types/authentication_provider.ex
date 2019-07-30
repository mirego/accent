defmodule Accent.GraphQL.Types.AuthenticationProvider do
  use Absinthe.Schema.Notation

  object :authentication_provider do
    field(:id, non_null(:id))
  end
end
