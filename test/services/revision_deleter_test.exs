defmodule AccentTest.RevisionDeleter do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Language
  alias Accent.Operation
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.RevisionManager
  alias Accent.Translation

  setup do
    project = Factory.insert(Project)
    french_language = Factory.insert(Language)
    english_language = Factory.insert(Language)

    master_revision = Factory.insert(Revision, language_id: french_language.id, project_id: project.id, master: true)

    slave_revision =
      Factory.insert(Revision,
        language_id: english_language.id,
        project_id: project.id,
        master: false,
        master_revision_id: master_revision.id
      )

    {:ok, [master_revision: master_revision, slave_revision: slave_revision]}
  end

  test "delete slave", %{slave_revision: revision} do
    {:ok, _revision} = RevisionManager.delete(revision)

    assert Repo.get(Revision, revision.id).marked_as_deleted
  end

  test "delete master", %{master_revision: revision} do
    {:error, changeset} = RevisionManager.delete(revision)

    assert changeset.errors == [master: {"can't delete master language", []}]
  end

  test "delete operations", %{slave_revision: revision} do
    operation = Factory.insert(Operation, action: "new", key: "a", revision_id: revision.id)

    Accent.Revisions.DeleteWorker.perform(%Oban.Job{args: %{"revision_id" => revision.id}})

    assert Repo.get(Operation, operation.id) == nil
  end

  test "delete translations", %{slave_revision: revision} do
    translation = Factory.insert(Translation, key: "a", revision_id: revision.id)

    Accent.Revisions.DeleteWorker.perform(%Oban.Job{args: %{"revision_id" => revision.id}})

    assert Repo.get(Translation, translation.id) == nil
  end
end
