defmodule Accent.Comment do
  use Accent.Schema

  import Ecto.Query, only: [from: 2]

  schema "comments" do
    field(:text, :string)

    belongs_to(:translation, Accent.Translation)
    belongs_to(:user, Accent.User)

    timestamps()
  end

  @required_fields ~w(text user_id translation_id)a

  def changeset(model, params) do
    model
    |> cast(params, @required_fields ++ [])
    |> validate_required(@required_fields)
    |> assoc_constraint(:user)
    |> assoc_constraint(:translation)
    |> prepare_changes(fn changeset ->
      from(t in Accent.Translation, where: t.id == ^changeset.changes[:translation_id])
      |> changeset.repo.update_all(inc: [comments_count: 1])

      changeset
    end)
  end
end
