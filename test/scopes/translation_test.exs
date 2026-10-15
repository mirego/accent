defmodule AccentTest.Scopes.Translation do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Document
  alias Accent.Operation
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Scopes.Translation, as: Scope
  alias Accent.Translation

  doctest Scope

  setup do
    project = Factory.insert(Project)

    {:ok, [project: project]}
  end

  describe "parse_added_last_sync/4" do
    setup %{project: project} do
      revision = Factory.insert(Revision, project_id: project.id)
      synced = Factory.insert(Translation, revision_id: revision.id, key: "synced")
      other = Factory.insert(Translation, revision_id: revision.id, key: "other")

      {:ok, [synced: synced, other: other]}
    end

    test "existing sync", %{project: project, synced: synced} do
      sync = Factory.insert(Operation, project_id: project.id, action: "sync")
      Factory.insert(Operation, batch_operation_id: sync.id, translation_id: synced.id, action: "new")

      assert added_last_sync_ids(project.id, nil) === [synced.id]
    end

    test "existing sync with document", %{project: project, synced: synced, other: other} do
      document = Factory.insert(Document, project_id: project.id, path: "my-test", format: "xliff_1_2")
      sync = Factory.insert(Operation, project_id: project.id, action: "sync", document_id: document.id)
      other_sync = Factory.insert(Operation, project_id: project.id, action: "sync")
      Factory.insert(Operation, batch_operation_id: sync.id, translation_id: synced.id, action: "new")
      Factory.insert(Operation, batch_operation_id: other_sync.id, translation_id: other.id, action: "new")

      assert added_last_sync_ids(project.id, document.id) === [synced.id]
    end

    test "many sync", %{project: project, synced: synced, other: other} do
      older =
        Factory.insert(Operation, project_id: project.id, action: "sync", inserted_at: ~U[2018-01-02T00:00:00.000000Z])

      latest =
        Factory.insert(Operation, project_id: project.id, action: "sync", inserted_at: ~U[2018-01-03T00:00:00.000000Z])

      Factory.insert(Operation, batch_operation_id: older.id, translation_id: other.id, action: "new")
      Factory.insert(Operation, batch_operation_id: latest.id, translation_id: synced.id, action: "new")

      assert added_last_sync_ids(project.id, nil) === [synced.id]
    end

    test "no syncs", %{project: project, synced: synced, other: other} do
      assert added_last_sync_ids(project.id, nil) === Enum.sort([synced.id, other.id])
    end
  end

  defp added_last_sync_ids(project_id, document_id) do
    Translation
    |> Scope.parse_added_last_sync(true, project_id, document_id)
    |> Repo.all()
    |> Enum.map(& &1.id)
    |> Enum.sort()
  end
end
