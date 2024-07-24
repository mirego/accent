defmodule AccentTest.CollaboratorNormalizer do
  @moduledoc false
  use Accent.RepoCase, async: true

  import Ecto.Query

  alias Accent.Collaborator
  alias Accent.Project
  alias Accent.Repo
  alias Accent.User
  alias Accent.UserRemote.CollaboratorNormalizer
  alias Faker.Internet

  test "create with many collaborations" do
    project = Factory.insert(Project)
    project2 = Factory.insert(Project)
    assigner = Factory.insert(User)

    collaborators = [
      struct!(
        Collaborator,
        Factory.build(Collaborator,
          email: Internet.email(),
          role: "admin",
          project_id: project.id,
          assigner_id: assigner.id
        )
      ),
      struct!(
        Collaborator,
        Factory.build(Collaborator,
          email: Internet.email(),
          role: "developer",
          project_id: project2.id,
          assigner_id: assigner.id
        )
      )
    ]

    collaborator_ids =
      collaborators
      |> Enum.map(&Collaborator.create_changeset(&1, %{"email" => "test@test.com"}))
      |> Enum.map(&Repo.insert!/1)
      |> Enum.map(&Map.get(&1, :id))

    new_user = Factory.insert(User, email: "test@test.com")

    %User{} = CollaboratorNormalizer.normalize(new_user)

    new_collaborators = Collaborator |> where([c], c.id in ^collaborator_ids) |> Repo.all()

    assert new_collaborators |> Enum.map(&Map.get(&1, :user_id)) |> Enum.uniq() === [new_user.id]
  end

  test "create with case insensitive email" do
    project = Factory.insert(Project)
    project2 = Factory.insert(Project)
    assigner = Factory.insert(User)

    collaborators = [
      struct!(
        Collaborator,
        Factory.build(Collaborator,
          email: Internet.email(),
          role: "admin",
          project_id: project.id,
          assigner_id: assigner.id
        )
      ),
      struct!(
        Collaborator,
        Factory.build(Collaborator,
          email: Internet.email(),
          role: "developer",
          project_id: project2.id,
          assigner_id: assigner.id
        )
      )
    ]

    collaborator_ids =
      collaborators
      |> Enum.map(&Collaborator.create_changeset(&1, %{"email" => "test@test.com"}))
      |> Enum.map(&Repo.insert!/1)
      |> Enum.map(&Map.get(&1, :id))

    new_user = Factory.insert(User, email: "Test@test.com")

    %User{} = CollaboratorNormalizer.normalize(new_user)

    new_collaborators = Collaborator |> where([c], c.id in ^collaborator_ids) |> Repo.all()

    assert new_collaborators |> Enum.map(&Map.get(&1, :user_id)) |> Enum.uniq() === [new_user.id]
  end

  test "create without collaborations" do
    new_user = Factory.insert(User, email: "Test@test.com")

    %User{} = CollaboratorNormalizer.normalize(new_user)

    new_collaborators = Repo.all(Collaborator)

    assert new_collaborators === []
  end
end
