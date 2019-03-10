defmodule AccentTest.Movement.Builders.ProjectSync do
  use Accent.RepoCase

  alias Accent.{
    Document,
    Language,
    ProjectCreator,
    Repo,
    Revision,
    Translation,
    User
  }

  alias Movement.Builders.ProjectSync, as: ProjectSyncBuilder
  alias Movement.Context

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})
    other_language = Repo.insert!(%Language{name: "French", slug: Ecto.UUID.generate()})
    {:ok, project} = ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)
    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    other_revision = Repo.insert!(%Revision{master: false, project_id: project.id, language_id: other_language.id})
    document = Repo.insert!(%Document{project_id: project.id, path: "test", format: "json"})

    {:ok, [revision: revision, document: document, project: project, other_revision: other_revision]}
  end

  test "builder fetch translations and use process operations", %{revision: revision, document: document, project: project, other_revision: other_revision} do
    %Translation{
      key: "a",
      proposed_text: "A",
      revision_id: revision.id,
      document_id: document.id
    }
    |> Repo.insert!()

    %Translation{
      key: "b",
      proposed_text: "B",
      revision_id: revision.id,
      document_id: document.id
    }
    |> Repo.insert!()

    %Translation{
      key: "a",
      proposed_text: "C",
      revision_id: other_revision.id,
      document_id: document.id
    }
    |> Repo.insert!()

    entries = [%Langue.Entry{key: "a", value: "B"}]

    context =
      %Context{entries: entries}
      |> Context.assign(:comparer, fn x, _y ->
        # Fake remove comparer in Movement.Builder
        if x.key == "b" do
          %Movement.Operation{action: "remove", key: x.key}
        else
          %Movement.Operation{action: "conflict_on_proposed", key: x.key}
        end
      end)
      |> Context.assign(:project, project)
      |> Context.assign(:document, document)
      |> ProjectSyncBuilder.build()

    operations = context.operations |> Enum.map(&Map.get(&1, :action))

    assert operations === ["conflict_on_proposed", "remove", "conflict_on_slave"]
  end
end
