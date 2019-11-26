defmodule AccentTest.Movement.Persisters.Base do
  use Accent.RepoCase

  import Ecto.Query

  alias Accent.{
    Operation,
    PreviousTranslation,
    Project,
    Repo,
    Revision,
    Translation,
    User,
    Version
  }

  alias Movement.Persisters.Base, as: BasePersister

  test "don’t overwrite revision" do
    revision = %Revision{} |> Repo.insert!()
    revision_two = %Revision{} |> Repo.insert!()

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

    %Movement.Context{operations: operations, assigns: %{revision: revision_two}}
    |> BasePersister.execute()

    [updated_translation] = Translation |> Repo.all()
    [operation] = Operation |> Repo.all()

    assert operation.action == "new"
    assert operation.key == "a"
    assert operation.text == "B"
    assert operation.revision_id == revision.id

    assert updated_translation.revision_id == revision.id
  end

  test "persist and execute empty operations" do
    {context, operations} =
      %Movement.Context{operations: []}
      |> BasePersister.execute()

    assert context.operations == []
    assert operations == []
  end

  test "persist and execute operations" do
    user = Repo.insert!(%User{email: "test@test.com"})
    revision = %Revision{} |> Repo.insert!()

    translation =
      %Translation{
        key: "a",
        proposed_text: "A",
        conflicted: true,
        revision_id: revision.id
      }
      |> Repo.insert!()

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

    %Movement.Context{operations: operations, assigns: %{user_id: user.id}}
    |> BasePersister.execute()

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
    translation =
      %Translation{
        key: "a",
        proposed_text: "A",
        conflicted: true,
        removed: true
      }
      |> Repo.insert!()

    operations = [
      %Movement.Operation{
        action: "new",
        key: "a",
        text: "B",
        previous_translation: %PreviousTranslation{
          removed: true
        }
      }
    ]

    %Movement.Context{operations: operations}
    |> BasePersister.execute()

    new_translation =
      Translation
      |> where([t], t.id != ^translation.id)
      |> Repo.one()

    assert new_translation.removed == true
  end

  test "version operation with source translation" do
    translation =
      %Translation{
        key: "a",
        proposed_text: "A",
        conflicted: true,
        removed: true
      }
      |> Repo.insert!()

    operations = [
      %Movement.Operation{
        action: "version_new",
        key: "a",
        text: "B",
        translation_id: translation.id
      }
    ]

    %Movement.Context{operations: operations}
    |> BasePersister.execute()

    new_translation =
      Translation
      |> where([t], t.id != ^translation.id)
      |> Repo.one()

    assert new_translation.source_translation_id == translation.id
  end

  test "version operation add operation on source translation" do
    translation =
      %Translation{
        key: "a",
        proposed_text: "A",
        conflicted: true,
        removed: true
      }
      |> Repo.insert!()

    operations = [
      %Movement.Operation{
        action: "version_new",
        key: "a",
        text: "B",
        translation_id: translation.id
      }
    ]

    %Movement.Context{operations: operations}
    |> BasePersister.execute()

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
    user = %User{email: "user@example.com"} |> Repo.insert!()
    project = %Project{main_color: "#f00", name: "project"} |> Repo.insert!()
    revision = %Revision{project_id: project.id} |> Repo.insert!()
    version = %Version{name: "foo", tag: "0.1", project: project, user: user} |> Repo.insert!()

    translation =
      %Translation{
        key: "a",
        proposed_text: "A",
        conflicted: true,
        removed: true,
        version: version
      }
      |> Repo.insert!()

    operations = [
      %Movement.Operation{
        action: "update",
        key: "a",
        text: "B",
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
