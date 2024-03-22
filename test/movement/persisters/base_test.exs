defmodule AccentTest.Movement.Persisters.Base do
  @moduledoc false
  use Accent.RepoCase, async: true

  import Ecto.Query

  alias Accent.Operation
  alias Accent.PreviousTranslation
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User
  alias Accent.Version
  alias Movement.Persisters.Base, as: BasePersister

  test "don’t overwrite revision" do
    revision = Factory.insert(Revision)
    revision_two = Factory.insert(Revision)

    translation = %Translation{
      key: "a",
      conflicted: true,
      revision_id: revision.id,
      revision: revision
    }

    operations = [
      %Movement.Operation{
        action: "new",
        key: "a",
        text: "B",
        translation_id: translation.id,
        revision_id: revision.id
      }
    ]

    BasePersister.execute(%Movement.Context{operations: operations, assigns: %{revision: revision_two}})
    [updated_translation] = Repo.all(Translation)
    [operation] = Repo.all(Operation)

    assert operation.action == "new"
    assert operation.key == "a"
    assert operation.text == "B"
    assert operation.revision_id == revision.id

    assert updated_translation.revision_id == revision.id
  end

  test "persist and execute empty operations" do
    {context, operations} = BasePersister.execute(%Movement.Context{operations: []})

    assert context.operations == []
    assert operations == []
  end

  test "persist and execute operations" do
    user = Factory.insert(User, email: "test@test.com")
    revision = Factory.insert(Revision)

    translation = Factory.insert(Translation, key: "a", proposed_text: "A", conflicted: true, revision_id: revision.id)

    operations = [
      %Movement.Operation{
        action: "update",
        key: "a",
        text: "B",
        translation_id: translation.id,
        revision_id: revision.id,
        value_type: "string",
        placeholders: []
      }
    ]

    BasePersister.execute(%Movement.Context{operations: operations, assigns: %{user_id: user.id}})

    operation =
      Operation
      |> where([o], o.batch == false)
      |> Repo.one()

    updated_translation =
      Translation
      |> where([t], t.id == ^translation.id)
      |> Repo.one()

    assert operation.action == "update"
    assert operation.key == "a"
    assert operation.text == "B"

    assert updated_translation.corrected_text == "B"
  end

  test "new operation with removed translation" do
    revision = Factory.insert(Revision)

    translation =
      Factory.insert(Translation,
        key: "a",
        proposed_text: "A",
        conflicted: true,
        removed: true,
        revision_id: revision.id
      )

    operations = [
      %Movement.Operation{
        action: "new",
        key: "a",
        text: "B",
        revision_id: revision.id,
        previous_translation: %PreviousTranslation{
          removed: true
        }
      }
    ]

    BasePersister.execute(%Movement.Context{operations: operations})

    new_translation =
      Translation
      |> where([t], t.id != ^translation.id)
      |> Repo.one()

    assert new_translation.removed == true
  end

  test "version operation with source translation" do
    revision = Factory.insert(Revision)

    translation =
      Factory.insert(Translation,
        key: "a",
        revision_id: revision.id,
        proposed_text: "A",
        conflicted: true,
        removed: true
      )

    operations = [
      %Movement.Operation{
        action: "version_new",
        key: "a",
        text: "B",
        revision_id: revision.id,
        translation_id: translation.id
      }
    ]

    BasePersister.execute(%Movement.Context{operations: operations})

    new_translation =
      Translation
      |> where([t], t.id != ^translation.id)
      |> Repo.one()

    assert new_translation.source_translation_id == translation.id
  end

  test "version operation add operation on source translation" do
    revision = Factory.insert(Revision)

    translation =
      Factory.insert(Translation,
        key: "a",
        revision_id: revision.id,
        proposed_text: "A",
        conflicted: true,
        removed: true
      )

    operations = [
      %Movement.Operation{
        action: "version_new",
        key: "a",
        text: "B",
        revision_id: revision.id,
        translation_id: translation.id
      }
    ]

    BasePersister.execute(%Movement.Context{operations: operations})

    new_translation =
      Translation
      |> where([t], t.id != ^translation.id)
      |> Repo.one()

    new_operation =
      Operation
      |> where([t], t.action == ^"add_to_version")
      |> Repo.one()

    assert new_operation.translation_id == new_translation.id
  end

  test "update operation add operation on version source translation" do
    user = Factory.insert(User, email: "user@example.com")
    project = Factory.insert(Project, main_color: "#f00", name: "project")
    revision = Factory.insert(Revision, project_id: project.id)
    version = Factory.insert(Version, name: "foo", tag: "0.1", project: project, user: user)

    translation =
      Factory.insert(Translation,
        key: "a",
        revision_id: revision.id,
        proposed_text: "A",
        conflicted: true,
        removed: true,
        version: version
      )

    operations = [
      %Movement.Operation{
        action: "update",
        key: "a",
        text: "B",
        revision_id: revision.id,
        value_type: "string",
        translation_id: translation.id,
        version_id: version.id
      }
    ]

    %Movement.Context{operations: operations, assigns: %{user_id: user.id, revision: revision}}
    |> Movement.Context.assign(:version, version)
    |> BasePersister.execute()

    updated_translation =
      Translation
      |> where([t], t.id == ^translation.id)
      |> Repo.one()

    assert updated_translation.corrected_text === "B"
    assert updated_translation.proposed_text === "A"
  end
end
