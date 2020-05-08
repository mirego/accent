defmodule Accent.Version do
  use Accent.Schema

  schema "versions" do
    field(:name, :string)
    field(:tag, :string)
    field(:parsed_tag, :any, virtual: true)

    belongs_to(:user, Accent.User)
    belongs_to(:project, Accent.Project)

    has_many(:translations, Accent.Translation)
    has_many(:operations, Accent.Operation)

    timestamps()
  end

  @required_fields ~w(project_id user_id name tag)a

  def changeset(model, params) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:tag, name: :versions_tag_project_id_index)
  end

  def with_parsed_tag(version) do
    version.tag
    |> String.trim_leading("v")
    |> Version.parse()
    |> case do
      {:ok, tag} -> %{version | parsed_tag: tag}
      _ -> %{version | parsed_tag: :error}
    end
  end
end
