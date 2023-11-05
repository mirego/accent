defmodule AccentTest.Movement.Builders.SlaveConflictSync do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Document
  alias Accent.Language
  alias Accent.ProjectCreator
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User
  alias Movement.Builders.SlaveConflictSync, as: SlaveConflictSyncBuilder
  alias Movement.Context

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})
    other_language = Repo.insert!(%Language{name: "French", slug: Ecto.UUID.generate()})

    {:ok, project} =
      ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)

    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    other_revision = Repo.insert!(%Revision{project_id: project.id, language_id: other_language.id})
    document = Repo.insert!(%Document{project_id: project.id, path: "test", format: "json"})

    {:ok, [project: project, revision: revision, document: document, other_revision: other_revision]}
  end

  test "builder fetch translations and use process operations", %{
    revision: revision,
    document: document,
    other_revision: other_revision
  } do
    translation =
      Repo.insert!(%Translation{key: "a", proposed_text: "A", revision_id: revision.id, document_id: document.id})

    other_translation =
      Repo.insert!(%Translation{key: "a", proposed_text: "C", revision_id: other_revision.id, document_id: document.id})

    context =
      %Context{operations: [%{key: "a", action: "conflict_on_proposed"}]}
      |> Context.assign(:revisions, [revision, other_revision])
      |> SlaveConflictSyncBuilder.build()

    operations = Enum.map(context.operations, &Map.get(&1, :action))

    translation_ids = Enum.map(context.assigns[:translations], &Map.get(&1, :id))

    assert Enum.member?(translation_ids, translation.id)
    assert Enum.member?(translation_ids, other_translation.id)
    assert operations === ["conflict_on_proposed", "conflict_on_slave", "conflict_on_slave"]
  end

  test "builder fetch translations multi documents and use process operations", %{
    project: project,
    revision: revision,
    document: document,
    other_revision: other_revision
  } do
    other_document = Repo.insert!(%Document{project_id: project.id, path: "other", format: "json"})

    translation =
      Repo.insert!(%Translation{key: "a", proposed_text: "A", revision_id: revision.id, document_id: document.id})

    other_translation =
      Repo.insert!(%Translation{
        key: "a",
        proposed_text: "C",
        revision_id: other_revision.id,
        document_id: other_document.id
      })

    context =
      %Context{operations: [%{key: "a", action: "conflict_on_proposed"}]}
      |> Context.assign(:revisions, [revision, other_revision])
      |> Context.assign(:document, document)
      |> SlaveConflictSyncBuilder.build()

    operations = Enum.map(context.operations, &Map.get(&1, :action))

    translation_ids = Enum.map(context.assigns[:translations], &Map.get(&1, :id))

    assert Enum.member?(translation_ids, translation.id)
    refute Enum.member?(translation_ids, other_translation.id)
    assert operations === ["conflict_on_proposed", "conflict_on_slave"]
  end
end
