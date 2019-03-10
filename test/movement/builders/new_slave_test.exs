defmodule AccentTest.Movement.Builders.NewSlave do
  use Accent.RepoCase

  alias Accent.{
    Document,
    Language,
    PreviousTranslation,
    ProjectCreator,
    Repo,
    Translation,
    User
  }

  alias Movement.Builders.NewSlave, as: NewSlaveBuilder

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})
    {:ok, project} = ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)
    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    document = Repo.insert!(%Document{project_id: project.id, path: "test", format: "json"})

    {:ok, [revision: revision, document: document, project: project]}
  end

  test "builder fetch translations and process operations", %{revision: revision, project: project, document: document} do
    translation =
      %Translation{
        key: "a",
        proposed_text: "A",
        corrected_text: "A",
        file_index: 2,
        file_comment: "comment",
        revision_id: revision.id,
        document_id: document.id
      }
      |> Repo.insert!()

    context =
      %Movement.Context{}
      |> Movement.Context.assign(:project, project)
      |> NewSlaveBuilder.build()

    translation_ids = context.assigns[:translations] |> Enum.map(&Map.get(&1, :id))
    operations = context.operations |> Enum.map(&Map.take(&1, [:key, :action, :text, :document_id, :file_comment, :file_index]))

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

  test "with removed translation", %{revision: revision, project: project, document: document} do
    translation =
      %Translation{
        key: "a",
        proposed_text: "A",
        corrected_text: "A",
        file_index: 2,
        file_comment: "comment",
        revision_id: revision.id,
        document_id: document.id,
        removed: true
      }
      |> Repo.insert!()

    context =
      %Movement.Context{}
      |> Movement.Context.assign(:project, project)
      |> NewSlaveBuilder.build()

    translation_ids = context.assigns[:translations] |> Enum.map(&Map.get(&1, :id))
    operations = context.operations |> Enum.map(&Map.take(&1, [:key, :action, :text, :document_id, :file_comment, :file_index, :previous_translation]))

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
