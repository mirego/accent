defmodule Accent.Document do
  use Accent.Schema

  require Accent.DocumentFormat

  schema "documents" do
    field(:path, :string)

    field(:format, :string)
    field(:render, :string, virtual: true)

    field(:top_of_the_file_comment, :string, default: "")
    field(:header, :string, default: "")

    belongs_to(:project, Accent.Project)
    has_many(:translations, Accent.Translation)

    field(:translations_count, :integer, virtual: true, default: :not_loaded)
    field(:reviewed_count, :integer, virtual: true, default: :not_loaded)
    field(:conflicts_count, :integer, virtual: true, default: :not_loaded)

    timestamps()
  end

  @possible_formats Accent.DocumentFormat.slugs()

  def changeset(model, params) do
    model
    |> cast(params, [:format, :project_id, :path, :top_of_the_file_comment, :header])
    |> validate_required([:format, :path, :project_id])
    |> validate_inclusion(:format, @possible_formats)
    |> unique_constraint(:path, name: :documents_path_format_project_id_index)
  end
end
