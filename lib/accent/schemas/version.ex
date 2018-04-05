defmodule Accent.Version do
  use Accent.Schema

  schema "versions" do
    field(:name, :string)
    field(:tag, :string)

    belongs_to(:user, Accent.User)
    belongs_to(:project, Accent.Project)

    has_many(:translations, Accent.Translation)
    has_many(:operations, Accent.Operation)

    timestamps()
  end

  @required_fields [:project_id, :user_id, :name, :tag]

  def changeset(model, params) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:tag, name: :versions_tag_project_id_index)
  end
end
