defmodule AccentTest.Movement.Builders.RevisionSyncSourceTranslationLink do
  @moduledoc false
  use Accent.RepoCase, async: true

  import Ecto.Query

  alias Accent.Document
  alias Accent.Language
  alias Accent.ProjectCreator
  alias Accent.Repo
  alias Accent.Translation
  alias Accent.User
  alias Accent.Version
  alias Movement.Builders.RevisionSync, as: RevisionSyncBuilder
  alias Movement.Comparers.SyncSmart
  alias Movement.Context
  alias Movement.Persisters.Base, as: BasePersister

  setup do
    user = Factory.insert(User)
    language = Factory.insert(Language)

    {:ok, project} =
      ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)

    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    document = Factory.insert(Document, project_id: project.id, path: "test", format: "json")

    {:ok, [project: project, revision: revision, document: document, user: user]}
  end

  describe "source_translation_id linking for versioned translations" do
    test "links versioned translation to new null-version translation when syncing", %{
      project: project,
      revision: revision,
      document: document,
      user: user
    } do
      # Create a version first (before the null-version translation exists)
      version =
        Factory.insert(Version,
          project_id: project.id,
          user_id: user.id,
          name: "v1.0",
          tag: "v1.0"
        )

      # Create a versioned translation WITHOUT a source_translation_id
      # (simulating the bug scenario where version was created before null-version translation)
      versioned_translation =
        Factory.insert(Translation,
          key: "hello",
          proposed_text: "Hello",
          corrected_text: "Hello",
          revision_id: revision.id,
          document_id: document.id,
          version_id: version.id,
          source_translation_id: nil
        )

      # Sync a null-version translation with the same key
      entries = [%Langue.Entry{key: "hello", value: "Hello World", value_type: "string"}]

      context =
        %Context{entries: entries}
        |> Context.assign(:comparer, &SyncSmart.compare/2)
        |> Context.assign(:document, document)
        |> Context.assign(:revision, revision)
        |> Context.assign(:project, project)
        |> Context.assign(:version, nil)
        |> RevisionSyncBuilder.build()

      # Execute the operations
      BasePersister.execute(context)

      # Verify the new null-version translation was created
      new_translation =
        Translation
        |> where(key: "hello", revision_id: ^revision.id)
        |> where([t], is_nil(t.version_id))
        |> Repo.one()

      assert new_translation
      assert new_translation.proposed_text == "Hello World"

      # Verify the versioned translation now has source_translation_id pointing to the new translation
      updated_versioned_translation = Repo.reload!(versioned_translation)

      assert updated_versioned_translation.source_translation_id == new_translation.id
    end

    test "does not link versioned translation if null-version translation already exists", %{
      project: project,
      revision: revision,
      document: document,
      user: user
    } do
      # Create a version
      version =
        Factory.insert(Version,
          project_id: project.id,
          user_id: user.id,
          name: "v1.0",
          tag: "v1.0"
        )

      # Create null-version translation first
      existing_translation =
        Factory.insert(Translation,
          key: "hello",
          proposed_text: "Hello",
          corrected_text: "Hello",
          revision_id: revision.id,
          document_id: document.id,
          version_id: nil
        )

      # Create a versioned translation with source_translation_id already set
      versioned_translation =
        Factory.insert(Translation,
          key: "hello",
          proposed_text: "Hello",
          corrected_text: "Hello",
          revision_id: revision.id,
          document_id: document.id,
          version_id: version.id,
          source_translation_id: existing_translation.id
        )

      # Sync the same key (should update existing, not create new)
      entries = [%Langue.Entry{key: "hello", value: "Hello Updated", value_type: "string"}]

      context =
        %Context{entries: entries}
        |> Context.assign(:comparer, &SyncSmart.compare/2)
        |> Context.assign(:document, document)
        |> Context.assign(:revision, revision)
        |> Context.assign(:project, project)
        |> Context.assign(:version, nil)
        |> RevisionSyncBuilder.build()

      BasePersister.execute(context)

      # Versioned translation should still point to original source
      updated_versioned_translation = Repo.reload!(versioned_translation)
      assert updated_versioned_translation.source_translation_id == existing_translation.id
    end

    test "only links versioned translations from the latest version", %{
      project: project,
      revision: revision,
      document: document,
      user: user
    } do
      # Create an older version
      old_version =
        Factory.insert(Version,
          project_id: project.id,
          user_id: user.id,
          name: "v1.0",
          tag: "v1.0",
          inserted_at: ~U[2024-01-01 00:00:00Z]
        )

      # Create a newer version
      new_version =
        Factory.insert(Version,
          project_id: project.id,
          user_id: user.id,
          name: "v2.0",
          tag: "v2.0",
          inserted_at: ~U[2025-01-01 00:00:00Z]
        )

      # Create orphaned versioned translation in OLD version
      old_versioned_translation =
        Factory.insert(Translation,
          key: "hello",
          proposed_text: "Hello Old",
          corrected_text: "Hello Old",
          revision_id: revision.id,
          document_id: document.id,
          version_id: old_version.id,
          source_translation_id: nil
        )

      # Create orphaned versioned translation in NEW version
      new_versioned_translation =
        Factory.insert(Translation,
          key: "hello",
          proposed_text: "Hello New",
          corrected_text: "Hello New",
          revision_id: revision.id,
          document_id: document.id,
          version_id: new_version.id,
          source_translation_id: nil
        )

      # Sync null-version translation
      entries = [%Langue.Entry{key: "hello", value: "Hello World", value_type: "string"}]

      context =
        %Context{entries: entries}
        |> Context.assign(:comparer, &SyncSmart.compare/2)
        |> Context.assign(:document, document)
        |> Context.assign(:revision, revision)
        |> Context.assign(:project, project)
        |> Context.assign(:version, nil)
        |> RevisionSyncBuilder.build()

      BasePersister.execute(context)

      # Only the latest version's translation should be linked
      updated_new_versioned = Repo.reload!(new_versioned_translation)
      updated_old_versioned = Repo.reload!(old_versioned_translation)

      new_translation =
        Translation
        |> where(key: "hello", revision_id: ^revision.id)
        |> where([t], is_nil(t.version_id))
        |> Repo.one()

      assert updated_new_versioned.source_translation_id == new_translation.id
      assert updated_old_versioned.source_translation_id == nil
    end

    test "does not link when syncing a versioned context", %{
      project: project,
      revision: revision,
      document: document,
      user: user
    } do
      # Create a version
      version =
        Factory.insert(Version,
          project_id: project.id,
          user_id: user.id,
          name: "v1.0",
          tag: "v1.0"
        )

      # Create orphaned versioned translation
      versioned_translation =
        Factory.insert(Translation,
          key: "hello",
          proposed_text: "Hello",
          corrected_text: "Hello",
          revision_id: revision.id,
          document_id: document.id,
          version_id: version.id,
          source_translation_id: nil
        )

      # Sync WITH a version context (not null-version sync)
      entries = [%Langue.Entry{key: "hello", value: "Hello Updated", value_type: "string"}]

      context =
        %Context{entries: entries}
        |> Context.assign(:comparer, &SyncSmart.compare/2)
        |> Context.assign(:document, document)
        |> Context.assign(:revision, revision)
        |> Context.assign(:project, project)
        |> Context.assign(:version, version)
        |> RevisionSyncBuilder.build()

      BasePersister.execute(context)

      # Should not affect source_translation_id since we're syncing with a version
      updated_versioned_translation = Repo.reload!(versioned_translation)
      assert updated_versioned_translation.source_translation_id == nil
    end
  end
end
