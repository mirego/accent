defmodule AccentTest.Movement.Builders.RevisionSync do
  use Accent.RepoCase

  alias Accent.{
    Document,
    Language,
    ProjectCreator,
    Repo,
    Translation,
    User
  }

  alias Movement.Builders.RevisionSync, as: RevisionSyncBuilder
  alias Movement.Context

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})
    {:ok, project} = ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)
    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    document = Repo.insert!(%Document{project_id: project.id, path: "test", format: "json"})

    {:ok, [revision: revision, document: document]}
  end

  test "builder fetch translations and use comparer", %{revision: revision, document: document} do
    translation =
      %Translation{
        key: "a",
        proposed_text: "A",
        revision_id: revision.id,
        document_id: document.id
      }
      |> Repo.insert!()

    entries = [%Langue.Entry{key: "a", value: "B"}]

    context =
      %Context{entries: entries}
      |> Context.assign(:comparer, fn x, _y -> %Movement.Operation{action: "conflict_on_proposed", key: x.key} end)
      |> Context.assign(:document, document)
      |> Context.assign(:revision, revision)
      |> RevisionSyncBuilder.build()

    translation_ids = context.assigns[:translations] |> Enum.map(&Map.get(&1, :id))
    operations = context.operations |> Enum.map(&Map.get(&1, :action))

    assert translation_ids === [translation.id]
    assert operations === ["conflict_on_proposed"]
  end

  test "builder fetch translations and process to remove with empty entries", %{revision: revision, document: document} do
    translation =
      %Translation{
        key: "a",
        proposed_text: "A",
        revision_id: revision.id,
        document_id: document.id
      }
      |> Repo.insert!()

    context =
      %Context{entries: []}
      |> Context.assign(:comparer, fn x, _y -> %Movement.Operation{action: "remove", key: x.key} end)
      |> Context.assign(:document, document)
      |> Context.assign(:revision, revision)
      |> RevisionSyncBuilder.build()

    translation_ids = context.assigns[:translations] |> Enum.map(&Map.get(&1, :id))
    operations = context.operations |> Enum.map(&Map.get(&1, :action))

    assert translation_ids === [translation.id]
    assert operations === ["remove"]
  end

  test "builder fetch translations and process to renew with entries", %{revision: revision, document: document} do
    translation =
      %Translation{
        key: "a",
        proposed_text: "A",
        revision_id: revision.id,
        document_id: document.id,
        removed: true
      }
      |> Repo.insert!()

    entries = [%Langue.Entry{key: "a", value: "B"}]

    context =
      %Context{entries: entries}
      |> Context.assign(:comparer, fn x, _y -> %Movement.Operation{action: "renew", key: x.key} end)
      |> Context.assign(:document, document)
      |> Context.assign(:revision, revision)
      |> RevisionSyncBuilder.build()

    translation_ids = context.assigns[:translations] |> Enum.map(&Map.get(&1, :id))
    operations = context.operations |> Enum.map(&Map.get(&1, :action))

    assert translation_ids === [translation.id]
    assert operations === ["renew"]
  end
end
