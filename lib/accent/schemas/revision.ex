defmodule Accent.Revision do
  use Accent.Schema

  schema "revisions" do
    field(:master, :boolean, default: true)

    belongs_to(:master_revision, Accent.Revision)
    belongs_to(:project, Accent.Project)
    belongs_to(:language, Accent.Language)

    has_many(:translations, Accent.Translation)
    has_many(:operations, Accent.Operation)

    field(:translations_count, :integer, virtual: true, default: :not_loaded)
    field(:reviewed_count, :integer, virtual: true, default: :not_loaded)
    field(:conflicts_count, :integer, virtual: true, default: :not_loaded)

    field(:translation_ids, {:array, :string}, virtual: true)

    timestamps()
  end

  @required_fields [:language_id, :project_id, :master_revision_id, :master]

  def changeset(model, params) do
    model
    |> cast(params, @required_fields ++ [])
    |> validate_required(@required_fields)
    |> unique_constraint(:language, name: :revisions_project_id_language_id_index)
  end

  def merge_stats(revision, stats) do
    translations_count = stats[revision.id][:active] || 0
    conflicts_count = stats[revision.id][:conflicted] || 0
    reviewed_count = translations_count - conflicts_count

    %{revision | translations_count: translations_count, conflicts_count: conflicts_count, reviewed_count: reviewed_count}
  end
end
