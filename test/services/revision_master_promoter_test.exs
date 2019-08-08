defmodule AccentTest.RevisionMasterPromoter do
  use Accent.RepoCase

  alias Accent.{Language, Project, Repo, Revision, RevisionManager}

  setup do
    french_language = %Language{name: "french"} |> Repo.insert!()
    english_language = %Language{name: "english"} |> Repo.insert!()
    project = %Project{main_color: "#f00", name: "My project"} |> Repo.insert!()

    master_revision = %Revision{language_id: french_language.id, project_id: project.id, master: true} |> Repo.insert!()
    slave_revision = %Revision{language_id: english_language.id, project_id: project.id, master: false, master_revision_id: master_revision.id} |> Repo.insert!()

    {:ok, [master_revision: master_revision, slave_revision: slave_revision]}
  end

  test "promote slave", %{slave_revision: revision, master_revision: master_revision} do
    {:ok, revision} = RevisionManager.promote(revision)

    old_master_revision = Repo.get(Revision, master_revision.id)

    assert old_master_revision.master == false
    assert old_master_revision.master_revision_id == revision.id
    assert revision.master == true
    assert revision.master_revision_id == nil
  end

  test "promote master", %{master_revision: revision} do
    {:error, changeset} = RevisionManager.promote(revision)

    assert changeset.errors == [master: {"invalid", []}]
  end
end
