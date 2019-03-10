defmodule AccentTest.ProjectDeleter do
  use Accent.RepoCase

  alias Accent.{Collaborator, Project, ProjectDeleter, Repo}

  test "create with language and user" do
    project = %Project{main_color: "#f00", name: "french"} |> Repo.insert!()
    collaborator = %Collaborator{project_id: project.id} |> Repo.insert!()

    assert project
           |> Ecto.assoc(:collaborators)
           |> Repo.all()
           |> Enum.map(& &1.id) === [collaborator.id]

    {:ok, project} = ProjectDeleter.delete(project: project)

    assert Repo.all(Ecto.assoc(project, :collaborators)) === []
  end
end
