defmodule AccentTest.CollaboratorNormalizer do
  use Accent.RepoCase

  import Ecto.Query

  alias Accent.{Collaborator, Project, Repo, User, UserRemote.CollaboratorNormalizer}

  test "create with many collaborations" do
    project = %Project{main_color: "#f00", name: "Ha"} |> Repo.insert!()
    project2 = %Project{main_color: "#f00", name: "Oh"} |> Repo.insert!()
    assigner = %User{email: "assigner@test.com"} |> Repo.insert!()

    collaborators = [
      %Collaborator{role: "admin", project_id: project.id, assigner_id: assigner.id},
      %Collaborator{role: "developer", project_id: project2.id, assigner_id: assigner.id}
    ]

    collaborator_ids =
      collaborators
      |> Enum.map(&Collaborator.create_changeset(&1, %{"email" => "test@test.com"}))
      |> Enum.map(&Repo.insert!/1)
      |> Enum.map(&Map.get(&1, :id))

    new_user = %User{email: "test@test.com"} |> Repo.insert!()

    %User{} = CollaboratorNormalizer.normalize(new_user)

    new_collaborators = Collaborator |> where([c], c.id in ^collaborator_ids) |> Repo.all()

    assert new_collaborators |> Enum.map(&Map.get(&1, :user_id)) |> Enum.uniq() === [new_user.id]
  end

  test "create with case insensitive email" do
    project = %Project{main_color: "#f00", name: "Ha"} |> Repo.insert!()
    project2 = %Project{main_color: "#f00", name: "Oh"} |> Repo.insert!()
    assigner = %User{email: "assigner@test.com"} |> Repo.insert!()

    collaborators = [
      %Collaborator{role: "admin", project_id: project.id, assigner_id: assigner.id},
      %Collaborator{role: "developer", project_id: project2.id, assigner_id: assigner.id}
    ]

    collaborator_ids =
      collaborators
      |> Enum.map(&Collaborator.create_changeset(&1, %{"email" => "test@test.com"}))
      |> Enum.map(&Repo.insert!/1)
      |> Enum.map(&Map.get(&1, :id))

    new_user = %User{email: "Test@test.com"} |> Repo.insert!()

    %User{} = CollaboratorNormalizer.normalize(new_user)

    new_collaborators = Collaborator |> where([c], c.id in ^collaborator_ids) |> Repo.all()

    assert new_collaborators |> Enum.map(&Map.get(&1, :user_id)) |> Enum.uniq() === [new_user.id]
  end

  test "create without collaborations" do
    new_user = %User{email: "Test@test.com"} |> Repo.insert!()

    %User{} = CollaboratorNormalizer.normalize(new_user)

    new_collaborators = Collaborator |> Repo.all()

    assert new_collaborators === []
  end
end
