defmodule AccentTest.Movement.Builders.NewVersion do
  use Accent.RepoCase

  alias Accent.{
    Document,
    Language,
    ProjectCreator,
    Repo,
    Translation,
    User,
    Version
  }

  alias Movement.Builders.NewVersion, as: NewVersionBuilder

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})
    {:ok, project} = ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)
    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    document = Repo.insert!(%Document{project_id: project.id, path: "test", format: "json"})

    {:ok, [revision: revision, document: document, project: project, user: user]}
  end

  test "builder fetch translations and process operations", %{revision: revision, project: project, document: document} do
    translation =
      %Translation{
        key: "a",
        proposed_text: "A",
        corrected_text: "A",
        file_index: 2,
        file_comment: "comment",
        plural: true,
        locked: true,
        revision_id: revision.id,
        document_id: document.id
      }
      |> Repo.insert!()

    context =
      %Movement.Context{}
      |> Movement.Context.assign(:project, project)
      |> NewVersionBuilder.build()

    translation_ids = context.assigns[:translations] |> Enum.map(&Map.get(&1, :id))
    operations = context.operations |> Enum.map(&Map.take(&1, [:key, :action, :text, :document_id, :file_comment, :file_index, :plural, :locked]))

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
    version = %Version{user_id: user.id, tag: "v3.2", name: "Release", project_id: project.id} |> Repo.insert!()

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

    %Translation{
      key: "a",
      proposed_text: "A",
      corrected_text: "A",
      file_index: 2,
      file_comment: "comment",
      revision_id: revision.id,
      version_id: version.id,
      document_id: document.id,
      source_translation_id: translation.id
    }
    |> Repo.insert!()

    context =
      %Movement.Context{}
      |> Movement.Context.assign(:project, project)
      |> NewVersionBuilder.build()

    translation_ids = context.assigns[:translations] |> Enum.map(&Map.get(&1, :id))
    operations = context.operations |> Enum.map(&Map.take(&1, [:key, :action, :text, :document_id, :file_comment, :file_index]))

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
