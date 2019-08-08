defmodule AccentTest.Movement.Persisters.NewSlave do
  use Accent.RepoCase

  alias Accent.{
    Language,
    ProjectCreator,
    Repo,
    User
  }

  alias Movement.Persisters.NewSlave, as: NewSlavePersister

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})
    {:ok, project} = ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)
    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()

    {:ok, [project: project, revision: revision]}
  end

  test "create revision success", %{project: project, revision: master_revision} do
    new_language = Repo.insert!(%Language{name: "French", slug: Ecto.UUID.generate()})

    {:ok, {context, _}} =
      %Movement.Context{assigns: %{project: project, language: new_language, master_revision: master_revision}}
      |> NewSlavePersister.persist()

    revision = context.assigns[:revision]

    assert revision.language_id == new_language.id
    assert revision.project_id == project.id
    assert revision.master_revision_id == master_revision.id
    assert revision.master == false
  end

  test "create revision error", %{project: project, revision: revision} do
    {:error, changeset} =
      %Movement.Context{assigns: %{project: project, language: %Language{}, master_revision: revision}}
      |> NewSlavePersister.persist()

    assert changeset.errors == [language_id: {"can't be blank", [validation: :required]}]
  end
end
