defmodule Accent.GraphQL.Types.APIToken do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  object :api_token do
    field(:id, non_null(:id))
    field(:token, non_null(:id))
    field(:custom_permissions, list_of(non_null(:string)))
    field(:user, non_null(:user), resolve: dataloader(Accent.User))
    field(:inserted_at, non_null(:datetime))
    field(:last_used_at, :datetime)
  end
end
