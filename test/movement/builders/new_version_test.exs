defmodule AccentTest.Movement.Builders.NewVersion do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Document
  alias Accent.Language
  alias Accent.ProjectCreator
  alias Accent.Repo
  alias Accent.Translation
  alias Accent.User
  alias Accent.Version
  alias Movement.Builders.NewVersion, as: NewVersionBuilder

  setup do
    user = Factory.insert(User)
    language = Factory.insert(Language)

    {:ok, project} =
      ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)

    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    document = Factory.insert(Document, project_id: project.id, path: "test", format: "json")

    {:ok, [revision: revision, document: document, project: project, user: user]}
  end

  test "builder fetch translations and process operations", %{revision: revision, project: project, document: document} do
    translation =
      Factory.insert(Translation,
        key: "a",
        proposed_text: "A",
        corrected_text: "A",
        file_index: 2,
        file_comment: "comment",
        plural: true,
        locked: true,
        revision_id: revision.id,
        document_id: document.id
      )

    context =
      %Movement.Context{}
      |> Movement.Context.assign(:project, project)
      |> NewVersionBuilder.build()

    translation_ids = Enum.map(context.assigns[:translations], &Map.get(&1, :id))

    operations =
      Enum.map(
        context.operations,
        &Map.take(&1, [:key, :action, :text, :document_id, :file_comment, :file_index, :plural, :locked])
      )

    assert translation_ids === [translation.id]

    assert operations == [
             %{
               key: translation.key,
               action: "version_new",
               text: "A",
               document_id: document.id,
               file_index: 2,
               file_comment: "comment",
               plural: true,
               locked: true
             }
           ]
  end

  test "builder with existing version", %{revision: revision, project: project, document: document, user: user} do
    version = Factory.insert(Version, user_id: user.id, tag: "v3.2", name: "Release", project_id: project.id)

    translation =
      Factory.insert(Translation,
        key: "a",
        proposed_text: "A",
        corrected_text: "A",
        file_index: 2,
        file_comment: "comment",
        revision_id: revision.id,
        document_id: document.id
      )

    Factory.insert(Translation,
      key: "a",
      proposed_text: "A",
      corrected_text: "A",
      file_index: 2,
      file_comment: "comment",
      revision_id: revision.id,
      version_id: version.id,
      document_id: document.id,
      source_translation_id: translation.id
    )

    context =
      %Movement.Context{}
      |> Movement.Context.assign(:project, project)
      |> NewVersionBuilder.build()

    translation_ids = Enum.map(context.assigns[:translations], &Map.get(&1, :id))

    operations =
      Enum.map(context.operations, &Map.take(&1, [:key, :action, :text, :document_id, :file_comment, :file_index]))

    assert translation_ids === [translation.id]

    assert operations == [
             %{
               key: translation.key,
               action: "version_new",
               text: "A",
               document_id: document.id,
               file_index: 2,
               file_comment: "comment"
             }
           ]
  end
end
