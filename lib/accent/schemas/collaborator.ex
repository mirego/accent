defmodule Accent.Collaborator do
  use Accent.Schema

  require Accent.Role

  schema "collaborators" do
    field(:email, :string)
    field(:role, :string)

    belongs_to(:user, Accent.User)
    belongs_to(:assigner, Accent.User)
    belongs_to(:project, Accent.Project)

    timestamps()
  end

  @required_fields ~w(email assigner_id role project_id)a
  @optional_fields ~w(user_id)a
  @possible_roles Accent.Role.slugs()

  def create_changeset(model, params) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> update_change(:email, &String.trim/1)
    |> validate_format(:email, ~r/.+@.+/)
    |> update_change(:email, &String.downcase/1)
    |> validate_inclusion(:role, @possible_roles)
    |> unique_constraint(:email, name: :collaborators_email_project_id_index)
  end

  def update_changeset(model, params) do
    model
    |> cast(params, [:role])
    |> validate_inclusion(:role, @possible_roles)
  end
end
