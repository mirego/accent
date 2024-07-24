defmodule AccentTest.RevisionMasterPromoter do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Language
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.RevisionManager

  setup do
    french_language = Factory.insert(Language)
    english_language = Factory.insert(Language)
    project = Factory.insert(Project)

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
