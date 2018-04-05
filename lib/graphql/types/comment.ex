defmodule Accent.GraphQL.Types.Comment do
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  object :comment do
    field(:id, non_null(:id))
    field(:text, non_null(:string))
    field(:translation, :translation, resolve: dataloader(Accent.Translation))
    field(:user, :user, resolve: dataloader(Accent.User))
    field(:inserted_at, non_null(:datetime))
  end

  object :comments do
    field(:meta, :pagination_meta)
    field(:entries, list_of(:comment))
  end

  object :translation_comments_subscription do
    field(:id, non_null(:id))
    field(:user, :user, resolve: dataloader(Accent.User))
    field(:translation, :translation, resolve: dataloader(Accent.Translation))
    field(:inserted_at, non_null(:datetime))
  end
end
