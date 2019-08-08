defmodule AccentTest.Movement.Builders.SlaveConflictSync do
  use Accent.RepoCase

  alias Movement.Builders.SlaveConflictSync, as: SlaveConflictSyncBuilder

  alias Accent.{
    Document,
    Language,
    ProjectCreator,
    Repo,
    Revision,
    Translation,
    User
  }

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})
    other_language = Repo.insert!(%Language{name: "French", slug: Ecto.UUID.generate()})
    {:ok, project} = ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)
    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    other_revision = Repo.insert!(%Revision{project_id: project.id, language_id: other_language.id})
    document = Repo.insert!(%Document{project_id: project.id, path: "test", format: "json"})

    {:ok, [revision: revision, document: document, other_revision: other_revision]}
  end

  test "builder fetch translations and use process operations", %{revision: revision, document: document, other_revision: other_revision} do
    translation =
      %Translation{
        key: "a",
        proposed_text: "A",
        revision_id: revision.id,
        document_id: document.id
      }
      |> Repo.insert!()

    other_translation =
      %Translation{
        key: "a",
        proposed_text: "C",
        revision_id: other_revision.id,
        document_id: document.id
      }
      |> Repo.insert!()

    context =
      %Movement.Context{operations: [%{key: "a", action: "conflict_on_proposed"}]}
      |> Movement.Context.assign(:revisions, [revision, other_revision])
      |> SlaveConflictSyncBuilder.build()

    operations = context.operations |> Enum.map(&Map.get(&1, :action))

    translation_ids = context.assigns[:translations] |> Enum.map(&Map.get(&1, :id))

    assert Enum.member?(translation_ids, translation.id)
    assert Enum.member?(translation_ids, other_translation.id)
    assert operations === ["conflict_on_proposed", "conflict_on_slave", "conflict_on_slave"]
  end
end
