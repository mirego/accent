defmodule AccentTest.Movement.Builders.ProjectSync do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Document
  alias Accent.Language
  alias Accent.ProjectCreator
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User
  alias Movement.Builders.ProjectSync, as: ProjectSyncBuilder
  alias Movement.Context

  setup do
    user = Factory.insert(User)
    language = Factory.insert(Language)
    other_language = Factory.insert(Language)

    {:ok, project} =
      ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)

    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    other_revision = Factory.insert(Revision, master: false, project_id: project.id, language_id: other_language.id)
    document = Factory.insert(Document, project_id: project.id, path: "test", format: "json")

    {:ok, [revision: revision, document: document, project: project, other_revision: other_revision]}
  end

  test "builder fetch translations and use process operations", %{
    revision: revision,
    document: document,
    project: project,
    other_revision: other_revision
  } do
    Factory.insert(Translation, key: "a", proposed_text: "A", revision_id: revision.id, document_id: document.id)
    Factory.insert(Translation, key: "b", proposed_text: "B", revision_id: revision.id, document_id: document.id)
    Factory.insert(Translation, key: "a", proposed_text: "C", revision_id: other_revision.id, document_id: document.id)
    entries = [%Langue.Entry{key: "a", value: "B", value_type: "string"}]

    context =
      %Context{entries: entries}
      |> Context.assign(:comparer, fn x, _y ->
        # Fake remove comparer in Movement.Builder
        if x.key == "b" do
          %Movement.Operation{action: "remove", key: x.key}
        else
          %Movement.Operation{action: "conflict_on_proposed", key: x.key}
        end
      end)
      |> Context.assign(:project, project)
      |> Context.assign(:document, document)
      |> ProjectSyncBuilder.build()

    operations = Enum.map(context.operations, &Map.get(&1, :action))

    assert operations === ["conflict_on_proposed", "remove", "conflict_on_slave"]
  end
end
