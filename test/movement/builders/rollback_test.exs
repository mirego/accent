defmodule AccentTest.Movement.Builders.Rollback do
  use Accent.RepoCase

  alias Movement.Builders.Rollback, as: RollbackBuilder

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

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})
    {:ok, project} = ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)
    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    document = Repo.insert!(%Document{project_id: project.id, path: "test", format: "json"})

    {:ok, [revision: revision, document: document, project: project]}
  end

  test "builder process operations for batch", %{project: project} do
    operation =
      %Operation{
        project_id: project.id,
        batch: true,
        action: "sync"
      }
      |> Repo.insert!()

    context =
      %Movement.Context{}
      |> Movement.Context.assign(:operation, operation)
      |> RollbackBuilder.build()

    [new_operation] = context.operations

    assert new_operation.action === "rollback"
    assert new_operation.rollbacked_operation_id === operation.id
  end

  test "builder process operations for translation", %{project: project, revision: revision, document: document} do
    translation =
      %Translation{
        key: "A",
        proposed_text: "TEXT",
        conflicted_text: "Ex-TEXT",
        corrected_text: "LOL",
        removed: false,
        revision_id: revision.id,
        value_type: "string",
        placeholders: []
      }
      |> Repo.insert!()

    operation =
      %Operation{
        text: "New text",
        key: "A",
        action: "update",
        translation_id: translation.id,
        revision_id: revision.id,
        project_id: project.id,
        document_id: document.id
      }
      |> Repo.insert!()
      |> Repo.preload(:translation)

    context =
      %Movement.Context{}
      |> Movement.Context.assign(:operation, operation)
      |> RollbackBuilder.build()

    [new_operation] = context.operations

    assert new_operation.action === "rollback"
    assert new_operation.rollbacked_operation_id === operation.id
    assert new_operation.translation_id === operation.translation_id
    assert new_operation.revision_id === operation.revision_id
    assert new_operation.project_id === operation.project_id
    assert new_operation.document_id === operation.document_id

    assert new_operation.previous_translation === %PreviousTranslation{
             value_type: translation.value_type,
             proposed_text: translation.proposed_text,
             corrected_text: translation.corrected_text,
             conflicted_text: translation.conflicted_text,
             conflicted: translation.conflicted,
             removed: translation.removed,
             placeholders: translation.placeholders
           }
  end
end
