defmodule Accent.GraphQL.Mutations.Comment do
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Authorization

  object :comment_mutations do
    field :create_comment, :mutated_comment do
      arg(:id, non_null(:id))
      arg(:text, non_null(:string))

      resolve(translation_authorize(:create_comment, &Accent.GraphQL.Resolvers.Comment.create/3))
    end

    field :delete_comment, :mutated_comment do
      arg(:id, non_null(:id))

      resolve(comment_authorize(:delete_comment, &Accent.GraphQL.Resolvers.Comment.delete/3))
    end

    field :create_translation_comments_subscription, :mutated_translation_comments_subscription do
      arg(:translation_id, non_null(:id))
      arg(:user_id, non_null(:id))

      resolve(translation_authorize(:create_translation_comments_subscription, &Accent.GraphQL.Resolvers.TranslationCommentSubscription.create/3))
    end

    field :delete_translation_comments_subscription, :mutated_translation_comments_subscription do
      arg(:id, non_null(:id))

      resolve(translation_comment_subscription_authorize(:delete_translation_comments_subscription, &Accent.GraphQL.Resolvers.TranslationCommentSubscription.delete/3))
    end
  end
end
