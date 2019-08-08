defmodule AccentTest.RevisionDeleter do
  use Accent.RepoCase

  alias Accent.{Language, Operation, Project, Repo, Revision, RevisionManager, Translation}

  setup do
    project = %Project{main_color: "#f00", name: "My project"} |> Repo.insert!()
    french_language = %Language{name: "french"} |> Repo.insert!()
    english_language = %Language{name: "english"} |> Repo.insert!()

    master_revision = %Revision{language_id: french_language.id, project_id: project.id, master: true} |> Repo.insert!()
    slave_revision = %Revision{language_id: english_language.id, project_id: project.id, master: false, master_revision_id: master_revision.id} |> Repo.insert!()

    {:ok, [master_revision: master_revision, slave_revision: slave_revision]}
  end

  test "delete slave", %{slave_revision: revision} do
    {:ok, _revision} = RevisionManager.delete(revision)

    assert Repo.get(Revision, revision.id) == nil
  end

  test "delete master", %{master_revision: revision} do
    {:error, changeset} = RevisionManager.delete(revision)

    assert changeset.errors == [master: {"can't delete master language", []}]
  end

  test "delete operations", %{slave_revision: revision} do
    operation = %Operation{action: "new", key: "a", revision_id: revision.id} |> Repo.insert!()

    {:ok, _revision} = RevisionManager.delete(revision)

    assert Repo.get(Operation, operation.id) == nil
  end

  test "delete translations", %{slave_revision: revision} do
    translation = %Translation{key: "a", revision_id: revision.id} |> Repo.insert!()

    {:ok, _revision} = RevisionManager.delete(revision)

    assert Repo.get(Translation, translation.id) == nil
  end
end
