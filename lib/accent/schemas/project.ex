defmodule Accent.Project do
  use Accent.Schema

  schema "projects" do
    field(:name, :string)
    field(:last_synced_at, :utc_datetime)
    field(:locked_file_operations, :boolean, default: false)

    has_many(:integrations, Accent.Integration)
    has_many(:revisions, Accent.Revision)
    has_many(:versions, Accent.Version)
    has_many(:operations, Accent.Operation)
    has_many(:collaborators, Accent.Collaborator)
    belongs_to(:language, Accent.Language)

    timestamps()
  end

  @optional_fields [
    :name,
    :last_synced_at,
    :locked_file_operations
  ]
  def changeset(model, params) do
    model
    |> cast(params, @optional_fields)
    |> validate_required([:name])
  end
end
