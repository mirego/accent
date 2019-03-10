defmodule AccentTest.Movement.Persisters.Rollback do
  use Accent.RepoCase

  import Ecto.Query

  alias Accent.{
    Document,
    Language,
    Operation,
    PreviousTranslation,
    ProjectCreator,
    Repo,
    Translation,
    User
  }

  alias Movement.Context
  alias Movement.Persisters.Rollback, as: RollbackPersister

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})
    {:ok, project} = ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)
    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    document = Repo.insert!(%Document{project_id: project.id, path: "test", format: "json"})

    {:ok, [project: project, document: document, revision: revision, user: user]}
  end

  test "persist operations", %{project: project, revision: revision, document: document, user: user} do
    translation =
      %Translation{
        key: "a",
        proposed_text: "A",
        conflicted: false,
        corrected_text: "Test",
        revision_id: revision.id,
        document_id: document.id
      }
      |> Repo.insert!()

    operation =
      %Accent.Operation{
        text: "B",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now(),
        action: "correct_conflict",
        translation: translation,
        previous_translation: PreviousTranslation.from_translation(translation),
        translation_id: translation.id,
        revision_id: translation.revision_id,
        project_id: project.id
      }
      |> Repo.insert!()

    operations = [
      %Movement.Operation{
        action: "rollback",
        translation_id: translation.id,
        revision_id: translation.revision_id,
        project_id: project.id,
        document_id: document.id,
        rollbacked_operation_id: operation.id
      }
    ]

    %Context{operations: operations}
    |> Context.assign(:project, project)
    |> Context.assign(:operation, operation)
    |> Context.assign(:revision, revision)
    |> Context.assign(:user_id, user.id)
    |> RollbackPersister.persist()

    correct_operation =
      Operation
      |> where([o], o.action == "correct_conflict")
      |> Repo.one()

    rollback_operation =
      Operation
      |> where([o], o.action == "rollback")
      |> Repo.one()

    updated_translation =
      Translation
      |> where([t], t.id == ^translation.id)
      |> Repo.one()

    assert correct_operation.rollbacked == true

    assert rollback_operation.rollbacked_operation_id == correct_operation.id

    assert updated_translation.proposed_text == "A"
    assert updated_translation.conflicted == false
  end

  test "rollback batch", %{revision: revision} do
    translation =
      %Translation{
        key: "a",
        corrected_text: "B",
        conflicted: true,
        revision_id: revision.id,
        revision: revision
      }
      |> Repo.insert!()

    %Operation{
      action: "new",
      key: "a",
      text: "B",
      translation_id: translation.id,
      revision_id: revision.id
    }
    |> Repo.insert!()

    batch_operation =
      %Operation{
        action: "sync",
        batch: true,
        revision_id: revision.id
      }
      |> Repo.insert!()

    operation =
      %Operation{
        action: "update",
        key: "a",
        text: "UPDATED",
        previous_translation: PreviousTranslation.from_translation(translation),
        translation_id: translation.id,
        revision_id: revision.id,
        batch_operation_id: batch_operation.id
      }
      |> Repo.insert!()

    rollback_operation = %Movement.Operation{
      action: "rollback",
      key: "a",
      batch: true,
      previous_translation: PreviousTranslation.from_translation(translation),
      rollbacked_operation_id: batch_operation.id
    }

    %Context{operations: [rollback_operation], assigns: %{operation: batch_operation}}
    |> RollbackPersister.persist()

    updated_operation = Repo.get(Operation, operation.id)
    updated_batch_operation = Repo.get(Operation, batch_operation.id)
    updated_rollback_operation = Operation |> where(action: ^"rollback") |> Repo.one()

    assert updated_operation.rollbacked == true
    assert updated_batch_operation.rollbacked == true
    assert updated_rollback_operation.batch == true
    assert updated_rollback_operation.rollbacked_operation_id == batch_operation.id
  end

  test "rollback rollback does nothing", %{revision: revision} do
    translation =
      %Translation{
        key: "a",
        corrected_text: "B",
        conflicted: true,
        revision_id: revision.id,
        revision: revision
      }
      |> Repo.insert!()

    %Operation{
      action: "new",
      key: "a",
      text: "B",
      translation_id: translation.id,
      revision_id: revision.id
    }
    |> Repo.insert!()

    operation =
      %Operation{
        action: "update",
        key: "a",
        text: "UPDATED",
        previous_translation: PreviousTranslation.from_translation(translation),
        translation_id: translation.id,
        revision_id: revision.id,
        rollbacked: true
      }
      |> Repo.insert!()

    rollback_operation =
      %Operation{
        action: "rollback",
        key: "a",
        previous_translation: PreviousTranslation.from_translation(translation),
        translation_id: translation.id,
        revision_id: revision.id,
        rollbacked_operation_id: operation.id
      }
      |> Repo.insert!()

    rollback_rollback_operation = %Movement.Operation{
      action: "rollback",
      key: "a",
      previous_translation: PreviousTranslation.from_translation(translation)
    }

    result =
      %Context{operations: [rollback_rollback_operation], assigns: %{operation: rollback_operation}}
      |> RollbackPersister.persist()

    assert result == {:error, :cannot_rollback_rollback}
  end
end
