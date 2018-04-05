defmodule Accent.GraphQL.Types.Role do
  use Absinthe.Schema.Notation

  enum :role do
    value(:bot, as: "bot")
    value(:owner, as: "owner")
    value(:admin, as: "admin")
    value(:developer, as: "developer")
    value(:reviewer, as: "reviewer")
  end

  object :role_item do
    field(:slug, non_null(:role))
  end
end
