defmodule Accent.GraphQL.Resolvers.TranslationCommentSubscription do
  alias Accent.{
    Repo,
    Translation,
    TranslationCommentsSubscription,
    Plugs.GraphQLContext
  }

  @typep translation_comments_subscription_operation :: {:ok, %{translation_comments_subscription: TranslationCommentsSubscription.t() | nil, errors: [String.t()] | nil}}

  @spec create(Translation.t(), %{user_id: String.t(), translation_id: String.t()}, GraphQLContext.t()) :: translation_comments_subscription_operation
  def create(translation, args, _info) do
    comment_subscription_params = %{
      "user_id" => args.user_id,
      "translation_id" => translation.id
    }

    %TranslationCommentsSubscription{}
    |> TranslationCommentsSubscription.changeset(comment_subscription_params)
    |> Repo.insert()
    |> case do
      {:ok, subscription} ->
        {:ok, %{translation_comments_subscription: subscription, errors: nil}}

      {:error, _reason} ->
        {:ok, %{translation_comments_subscription: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec delete(TranslationCommentsSubscription.t(), any(), GraphQLContext.t()) :: translation_comments_subscription_operation
  def delete(translation_comments_subscription, _args, _info) do
    translation_comments_subscription
    |> Repo.delete()
    |> case do
      {:ok, _} ->
        {:ok, %{translation_comments_subscription: nil, errors: nil}}

      {:error, _} ->
        {:ok, %{translation_comments_subscription: translation_comments_subscription, errors: ["unprocessable_entity"]}}
    end
  end
end
