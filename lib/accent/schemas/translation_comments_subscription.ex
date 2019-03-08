defmodule Accent.TranslationCommentsSubscription do
  use Accent.Schema

  schema "translation_comments_subscriptions" do
    belongs_to(:user, Accent.User)
    belongs_to(:translation, Accent.Translation)

    timestamps()
  end

  @required_fields ~w(
    user_id
    translation_id
  )a
  def changeset(model, params) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:user, name: :translation_comments_subscriptions_user_id_translation_id_index)
  end
end
