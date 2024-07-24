defmodule AccentTest.ProjectDeleter do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Collaborator
  alias Accent.Language
  alias Accent.Operation
  alias Accent.Project
  alias Accent.ProjectDeleter
  alias Accent.Repo
  alias Accent.Revision

  test "delete collaborators and operations" do
    project = Factory.insert(Project)
    language = Factory.insert(Language)
    revision = Factory.insert(Revision, language_id: language.id, project_id: project.id)
    collaborator = Factory.insert(Collaborator, project_id: project.id, role: "reviewer")

    Factory.insert(Operation, project_id: project.id, action: "sync")
    Factory.insert(Operation, project_id: project.id, revision_id: revision.id, action: "merge")

    assert project
           |> Ecto.assoc(:all_collaborators)
           |> Repo.all()
           |> Enum.map(& &1.id) === [collaborator.id]

    {:ok, project} = ProjectDeleter.delete(project: project)

    assert Repo.aggregate(Ecto.assoc(project, :all_collaborators), :count) === 0
    assert Repo.aggregate(Ecto.assoc(project, :operations), :count) === 0
    assert Repo.aggregate(Ecto.assoc(revision, :operations), :count) === 0
  end
end
