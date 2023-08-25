defmodule AccentTest.CollaboratorNormalizer do
  @moduledoc false
  use Accent.RepoCase

  import Ecto.Query

  alias Accent.Collaborator
  alias Accent.Project
  alias Accent.Repo
  alias Accent.User
  alias Accent.UserRemote.CollaboratorNormalizer

  test "create with many collaborations" do
    project = Repo.insert!(%Project{main_color: "#f00", name: "Ha"})
    project2 = Repo.insert!(%Project{main_color: "#f00", name: "Oh"})
    assigner = Repo.insert!(%User{email: "assigner@test.com"})

    collaborators = [
      %Collaborator{role: "admin", project_id: project.id, assigner_id: assigner.id},
      %Collaborator{role: "developer", project_id: project2.id, assigner_id: assigner.id}
    ]

    collaborator_ids =
      collaborators
      |> Enum.map(&Collaborator.create_changeset(&1, %{"email" => "test@test.com"}))
      |> Enum.map(&Repo.insert!/1)
      |> Enum.map(&Map.get(&1, :id))

    new_user = Repo.insert!(%User{email: "test@test.com"})

    %User{} = CollaboratorNormalizer.normalize(new_user)

    new_collaborators = Collaborator |> where([c], c.id in ^collaborator_ids) |> Repo.all()

    assert new_collaborators |> Enum.map(&Map.get(&1, :user_id)) |> Enum.uniq() === [new_user.id]
  end

  test "create with case insensitive email" do
    project = Repo.insert!(%Project{main_color: "#f00", name: "Ha"})
    project2 = Repo.insert!(%Project{main_color: "#f00", name: "Oh"})
    assigner = Repo.insert!(%User{email: "assigner@test.com"})

    collaborators = [
      %Collaborator{role: "admin", project_id: project.id, assigner_id: assigner.id},
      %Collaborator{role: "developer", project_id: project2.id, assigner_id: assigner.id}
    ]

    collaborator_ids =
      collaborators
      |> Enum.map(&Collaborator.create_changeset(&1, %{"email" => "test@test.com"}))
      |> Enum.map(&Repo.insert!/1)
      |> Enum.map(&Map.get(&1, :id))

    new_user = Repo.insert!(%User{email: "Test@test.com"})

    %User{} = CollaboratorNormalizer.normalize(new_user)

    new_collaborators = Collaborator |> where([c], c.id in ^collaborator_ids) |> Repo.all()

    assert new_collaborators |> Enum.map(&Map.get(&1, :user_id)) |> Enum.uniq() === [new_user.id]
  end

  test "create without collaborations" do
    new_user = Repo.insert!(%User{email: "Test@test.com"})

    %User{} = CollaboratorNormalizer.normalize(new_user)

    new_collaborators = Repo.all(Collaborator)

    assert new_collaborators === []
  end
end
