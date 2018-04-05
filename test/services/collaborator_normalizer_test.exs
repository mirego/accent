defmodule AccentTest.CollaboratorNormalizer do
  use Accent.RepoCase
  require Ecto.Query

  alias Accent.{Repo, Project, User, Collaborator, UserRemote.CollaboratorNormalizer}

  test "create with many collaborations" do
    project = %Project{name: "Ha"} |> Repo.insert!()
    project2 = %Project{name: "Oh"} |> Repo.insert!()
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

    :ok = CollaboratorNormalizer.normalize(new_user)

    new_collaborators = Collaborator |> Ecto.Query.where([c], c.id in ^collaborator_ids) |> Repo.all()

    assert new_collaborators |> Enum.map(&Map.get(&1, :user_id)) |> Enum.uniq() === [new_user.id]
  end

  test "create with case insensitive email" do
    project = %Project{name: "Ha"} |> Repo.insert!()
    project2 = %Project{name: "Oh"} |> Repo.insert!()
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

    :ok = CollaboratorNormalizer.normalize(new_user)

    new_collaborators = Collaborator |> Ecto.Query.where([c], c.id in ^collaborator_ids) |> Repo.all()

    assert new_collaborators |> Enum.map(&Map.get(&1, :user_id)) |> Enum.uniq() === [new_user.id]
  end

  test "create without collaborations" do
    new_user = %User{email: "Test@test.com"} |> Repo.insert!()

    :ok = CollaboratorNormalizer.normalize(new_user)

    new_collaborators = Collaborator |> Repo.all()

    assert new_collaborators === []
  end
end
