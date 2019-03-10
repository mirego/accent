defmodule AccentTest.Movement.Persisters.NewVersion do
  use Accent.RepoCase

  import Ecto.Query

  alias Accent.{
    Document,
    Language,
    Operation,
    ProjectCreator,
    Repo,
    Translation,
    User,
    Version
  }

  alias Movement.Context
  alias Movement.Persisters.NewVersion, as: NewVersionPersister

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})
    {:ok, project} = ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)
    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    document = Repo.insert!(%Document{project_id: project.id, path: "test", format: "json"})

    {:ok, [revision: revision, document: document, project: project, user: user]}
  end

  test "builder fetch translations and process operations", %{revision: revision, user: user, project: project, document: document} do
    translation =
      %Translation{
        key: "a",
        proposed_text: "A",
        corrected_text: "A",
        file_index: 2,
        file_comment: "comment",
        plural: true,
        locked: true,
        revision_id: revision.id,
        document_id: document.id
      }
      |> Repo.insert!()

    operations = [
      %Movement.Operation{
        action: "version_new",
        key: "a",
        text: "B",
        translation_id: translation.id,
        value_type: "string",
        placeholders: []
      }
    ]

    %Context{operations: operations}
    |> Context.assign(:user_id, user.id)
    |> Context.assign(:project, project)
    |> Context.assign(:name, "My new version 0.1")
    |> Context.assign(:tag, "v0.1")
    |> NewVersionPersister.persist()

    new_version =
      Version
      |> where([v], v.tag == ^"v0.1")
      |> Repo.one()

    batch_operation =
      Operation
      |> where([o], o.batch == true)
      |> Repo.one()

    version_translation =
      Translation
      |> where([t], t.version_id == ^new_version.id)
      |> Repo.one()

    assert batch_operation.action === "create_version"
    assert batch_operation.stats === [%{"action" => "version_new", "count" => 1}]
    assert version_translation.key === "a"
    assert version_translation.proposed_text === "B"
    assert version_translation.value_type === "string"
  end
end
