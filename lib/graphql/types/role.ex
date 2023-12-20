defmodule Accent.GraphQL.Types.Role do
  @moduledoc false
  use Absinthe.Schema.Notation

  enum :role do
    value(:bot, as: "bot")
    value(:owner, as: "owner")
    value(:admin, as: "admin")
    value(:developer, as: "developer")
    value(:translator, as: "translator")
    value(:reviewer, as: "reviewer")
  end

  object :role_item do
    field(:slug, non_null(:role))
  end
end
