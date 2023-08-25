defmodule AccentTest.ProjectDeleter do
  @moduledoc false
  use Accent.RepoCase

  alias Accent.Collaborator
  alias Accent.Project
  alias Accent.ProjectDeleter
  alias Accent.Repo

  test "create with language and user" do
    project = Repo.insert!(%Project{main_color: "#f00", name: "french"})
    collaborator = Repo.insert!(%Collaborator{project_id: project.id, role: "reviewer"})

    assert project
           |> Ecto.assoc(:all_collaborators)
           |> Repo.all()
           |> Enum.map(& &1.id) === [collaborator.id]

    {:ok, project} = ProjectDeleter.delete(project: project)

    assert Repo.all(Ecto.assoc(project, :all_collaborators)) === []
  end
end
