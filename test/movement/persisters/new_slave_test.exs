defmodule AccentTest.Movement.Persisters.NewSlave do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Language
  alias Accent.ProjectCreator
  alias Accent.Repo
  alias Accent.User
  alias Movement.Persisters.NewSlave, as: NewSlavePersister

  setup do
    user = Factory.insert(User)
    language = Factory.insert(Language)

    {:ok, project} =
      ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)

    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()

    {:ok, [project: project, revision: revision]}
  end

  test "create revision success", %{project: project, revision: master_revision} do
    new_language = Factory.insert(Language)

    {:ok, {context, _}} =
      NewSlavePersister.persist(%Movement.Context{
        assigns: %{project: project, language: new_language, master_revision: master_revision}
      })

    revision = context.assigns[:revision]

    assert revision.language_id == new_language.id
    assert revision.project_id == project.id
    assert revision.master_revision_id == master_revision.id
    assert revision.master == false
  end

  test "create revision error", %{project: project, revision: revision} do
    {:error, changeset} =
      NewSlavePersister.persist(%Movement.Context{
        assigns: %{project: project, language: %Language{}, master_revision: revision}
      })

    assert changeset.errors == [language_id: {"can't be blank", [validation: :required]}]
  end
end
