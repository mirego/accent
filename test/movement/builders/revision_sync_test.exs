defmodule AccentTest.Movement.Builders.RevisionSync do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Document
  alias Accent.Language
  alias Accent.ProjectCreator
  alias Accent.Repo
  alias Accent.Translation
  alias Accent.User
  alias Movement.Builders.RevisionSync, as: RevisionSyncBuilder
  alias Movement.Context

  setup do
    user = Factory.insert(User)
    language = Factory.insert(Language)

    {:ok, project} =
      ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)

    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    document = Factory.insert(Document, project_id: project.id, path: "test", format: "json")

    {:ok, [project: project, revision: revision, document: document]}
  end

  test "builder fetch translations and use comparer", %{project: project, revision: revision, document: document} do
    translation =
      Factory.insert(Translation, key: "a", proposed_text: "A", revision_id: revision.id, document_id: document.id)

    entries = [%Langue.Entry{key: "a", value: "B", value_type: "string"}]

    context =
      %Context{entries: entries}
      |> Context.assign(:comparer, fn x, _y -> %Movement.Operation{action: "conflict_on_proposed", key: x.key} end)
      |> Context.assign(:project, project)
      |> Context.assign(:document, document)
      |> Context.assign(:revision, revision)
      |> RevisionSyncBuilder.build()

    translation_ids = Enum.map(context.assigns[:translations], &Map.get(&1, :id))
    operations = Enum.map(context.operations, &Map.get(&1, :action))

    assert translation_ids === [translation.id]
    assert operations === ["conflict_on_proposed"]
  end

  test "builder fetch translations and process to remove with empty entries", %{
    project: project,
    revision: revision,
    document: document
  } do
    translation =
      Factory.insert(Translation, key: "a", proposed_text: "A", revision_id: revision.id, document_id: document.id)

    context =
      %Context{entries: []}
      |> Context.assign(:comparer, fn x, _y -> %Movement.Operation{action: "remove", key: x.key} end)
      |> Context.assign(:project, project)
      |> Context.assign(:document, document)
      |> Context.assign(:revision, revision)
      |> RevisionSyncBuilder.build()

    translation_ids = Enum.map(context.assigns[:translations], &Map.get(&1, :id))
    operations = Enum.map(context.operations, &Map.get(&1, :action))

    assert translation_ids === [translation.id]
    assert operations === ["remove"]
  end

  test "builder fetch translations and process to renew with entries", %{
    project: project,
    revision: revision,
    document: document
  } do
    translation =
      Factory.insert(Translation,
        key: "a",
        proposed_text: "A",
        revision_id: revision.id,
        document_id: document.id,
        removed: true
      )

    entries = [%Langue.Entry{key: "a", value: "B", value_type: "string"}]

    context =
      %Context{entries: entries}
      |> Context.assign(:comparer, fn x, _y -> %Movement.Operation{action: "renew", key: x.key} end)
      |> Context.assign(:project, project)
      |> Context.assign(:document, document)
      |> Context.assign(:revision, revision)
      |> RevisionSyncBuilder.build()

    translation_ids = Enum.map(context.assigns[:translations], &Map.get(&1, :id))
    operations = Enum.map(context.operations, &Map.get(&1, :action))

    assert translation_ids === [translation.id]
    assert operations === ["renew"]
  end
end
