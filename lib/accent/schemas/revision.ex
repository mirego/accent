defmodule Accent.Revision do
  use Accent.Schema

  schema "revisions" do
    field(:master, :boolean, default: true)

    field(:name, :string)
    field(:slug, :string)
    field(:iso_639_1, :string)
    field(:iso_639_3, :string)
    field(:locale, :string)
    field(:android_code, :string)
    field(:osx_code, :string)
    field(:osx_locale, :string)
    field(:plural_forms, :string)

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

  @required_fields ~w(language_id project_id master_revision_id master)a

  def changeset(model, params) do
    model
    |> cast(params, @required_fields ++ [])
    |> validate_required(@required_fields)
    |> unique_constraint(:language, name: :revisions_project_id_language_id_index)
  end

  def language(revision) do
    language_override =
      revision
      |> Map.take(~w(
      name
      slug
      iso_639_1
      iso_639_3
      locale
      android_code
      osx_code
      osx_locale
      plural_forms
    )a)
      |> Enum.reject(fn {_key, value} -> value in [nil, ""] end)
      |> Enum.into(%{})

    Map.merge(revision.language, language_override)
  end
end
