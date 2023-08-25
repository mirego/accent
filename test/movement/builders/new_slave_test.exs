defmodule AccentTest.Movement.Builders.NewSlave do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Document
  alias Accent.Language
  alias Accent.PreviousTranslation
  alias Accent.ProjectCreator
  alias Accent.Repo
  alias Accent.Translation
  alias Accent.User
  alias Movement.Builders.NewSlave, as: NewSlaveBuilder
  alias Movement.Context

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})

    {:ok, project} =
      ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)

    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    document = Repo.insert!(%Document{project_id: project.id, path: "test", format: "json"})

    {:ok, [revision: revision, document: document, project: project]}
  end

  test "builder fetch translations and process operations", %{revision: revision, project: project, document: document} do
    translation =
      Repo.insert!(%Translation{
        key: "a",
        proposed_text: "A",
        corrected_text: "A",
        file_index: 2,
        file_comment: "comment",
        revision_id: revision.id,
        document_id: document.id
      })

    context =
      %Context{}
      |> Context.assign(:project, project)
      |> Context.assign(:new_slave_options, [])
      |> NewSlaveBuilder.build()

    translation_ids = Enum.map(context.assigns[:translations], &Map.get(&1, :id))

    operations =
      Enum.map(context.operations, &Map.take(&1, [:key, :action, :text, :document_id, :file_comment, :file_index]))

    assert translation_ids === [translation.id]

    assert operations === [
             %{
               key: translation.key,
               action: "new",
               text: "A",
               document_id: document.id,
               file_index: 2,
               file_comment: "comment"
             }
           ]
  end

  test "builder fetch translations and process operations with default null", %{
    revision: revision,
    project: project,
    document: document
  } do
    translation =
      Repo.insert!(%Translation{
        key: "a",
        proposed_text: "A",
        corrected_text: "A",
        file_index: 2,
        file_comment: "comment",
        revision_id: revision.id,
        document_id: document.id
      })

    context =
      %Context{}
      |> Context.assign(:project, project)
      |> Context.assign(:new_slave_options, ["default_null"])
      |> NewSlaveBuilder.build()

    translation_ids = Enum.map(context.assigns[:translations], &Map.get(&1, :id))
    operations = Enum.map(context.operations, &Map.take(&1, [:text]))

    assert translation_ids === [translation.id]
    assert operations === [%{text: ""}]
  end

  test "with removed translation", %{revision: revision, project: project, document: document} do
    translation =
      Repo.insert!(%Translation{
        key: "a",
        proposed_text: "A",
        corrected_text: "A",
        file_index: 2,
        file_comment: "comment",
        revision_id: revision.id,
        document_id: document.id,
        removed: true
      })

    context =
      %Context{}
      |> Context.assign(:project, project)
      |> Context.assign(:new_slave_options, [])
      |> NewSlaveBuilder.build()

    translation_ids = Enum.map(context.assigns[:translations], &Map.get(&1, :id))

    operations =
      Enum.map(
        context.operations,
        &Map.take(&1, [:key, :action, :text, :document_id, :file_comment, :file_index, :previous_translation])
      )

    assert translation_ids === [translation.id]

    assert operations === [
             %{
               key: translation.key,
               action: "new",
               text: "A",
               document_id: document.id,
               file_index: 2,
               file_comment: "comment",
               previous_translation: %PreviousTranslation{
                 value_type: "string",
                 removed: true,
                 conflicted: false,
                 conflicted_text: "",
                 corrected_text: "A",
                 proposed_text: "A",
                 placeholders: []
               }
             }
           ]
  end
end
