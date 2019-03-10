defmodule AccentTest.Movement.Persisters.ProjectSync do
  use Accent.RepoCase

  import Ecto.Query

  alias Accent.{
    Document,
    Language,
    Operation,
    ProjectCreator,
    Repo,
    Translation,
    User
  }

  alias Movement.Context
  alias Movement.Persisters.ProjectSync, as: ProjectSyncPersister

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
        revision_id: revision.id,
        document_id: document.id
      }
      |> Repo.insert!()

    operations = [
      %Movement.Operation{
        action: "conflict_on_corrected",
        key: "a",
        text: "B",
        translation_id: translation.id,
        value_type: "string",
        placeholders: []
      }
    ]

    %Context{operations: operations}
    |> Context.assign(:project, project)
    |> Context.assign(:document, document)
    |> Context.assign(:revision, revision)
    |> Context.assign(:user_id, user.id)
    |> ProjectSyncPersister.persist()

    batch_operation =
      Operation
      |> where([o], o.batch == true)
      |> Repo.one()

    operation =
      Operation
      |> where([o], o.batch == false)
      |> Repo.one()

    updated_translation =
      Translation
      |> where([t], t.id == ^translation.id)
      |> Repo.one()

    assert batch_operation.project_id == project.id
    assert batch_operation.revision_id == revision.id
    assert batch_operation.document_id == document.id
    assert batch_operation.user_id == user.id
    assert batch_operation.action == "sync"

    assert batch_operation.stats == [
             %{
               "action" => "conflict_on_corrected",
               "count" => 1
             }
           ]

    assert operation.action == "conflict_on_corrected"
    assert operation.batch_operation_id == batch_operation.id
    assert operation.key == "a"
    assert operation.text == "B"

    assert updated_translation.proposed_text == "B"
  end

  test "persist document", %{project: project, revision: revision, user: user} do
    operations = [
      %Movement.Operation{
        action: "new",
        key: "a",
        text: "A"
      }
    ]

    %Context{operations: operations}
    |> Context.assign(:project, project)
    |> Context.assign(:document, %Document{project_id: project.id, path: "new-doc", format: "json"})
    |> Context.assign(:revision, revision)
    |> Context.assign(:user_id, user.id)
    |> ProjectSyncPersister.persist()

    new_document =
      Document
      |> where([d], d.path == "new-doc")
      |> where([d], d.format == "json")
      |> Repo.one()

    assert new_document.project_id == project.id
  end

  test "persist document update", %{project: project, revision: revision, document: document, user: user} do
    operations = [
      %Movement.Operation{
        action: "new",
        key: "a",
        text: "A"
      }
    ]

    %Context{operations: operations}
    |> Context.assign(:project, project)
    |> Context.assign(:document, document)
    |> Context.assign(:document_update, %{top_of_the_file_comment: "hello", header: "foobar"})
    |> Context.assign(:revision, revision)
    |> Context.assign(:user_id, user.id)
    |> ProjectSyncPersister.persist()

    new_document =
      Document
      |> Repo.get(document.id)

    assert new_document.top_of_the_file_comment == "hello"
    assert new_document.header == "foobar"
  end
end
