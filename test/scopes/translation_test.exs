defmodule AccentTest.Scopes.Translation do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Document
  alias Accent.Operation
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Scopes.Translation, as: Scope
  alias Accent.Translation

  doctest Accent.Scopes.Translation

  setup do
    project = Repo.insert!(%Project{main_color: "#f00", name: "My project"})

    {:ok, [project: project]}
  end

  describe "parse_added_last_sync/3" do
    test "existing sync", %{project: project} do
      sync = Repo.insert!(%Operation{project: project, action: "sync"})

      query = Scope.parse_added_last_sync(Translation, true, project.id, nil)

      assert inspect(query) ===
               "#Ecto.Query<from t0 in Accent.Translation, join: o1 in assoc(t0, :operations), where: o1.batch_operation_id == ^\"#{sync.id}\">"
    end

    test "existing sync with document", %{project: project} do
      document = Repo.insert!(%Document{project_id: project.id, path: "my-test", format: "xliff_1_2"})
      sync = Repo.insert!(%Operation{project: project, action: "sync", document: document})
      _other_sync = Repo.insert!(%Operation{project: project, action: "sync"})

      query = Scope.parse_added_last_sync(Translation, true, project.id, document.id)

      assert inspect(query) ===
               "#Ecto.Query<from t0 in Accent.Translation, join: o1 in assoc(t0, :operations), where: o1.batch_operation_id == ^\"#{sync.id}\">"
    end

    test "many sync", %{project: project} do
      _ = Repo.insert!(%Operation{project: project, action: "sync", inserted_at: ~U[2018-01-02T00:00:00.000000Z]})
      sync = Repo.insert!(%Operation{project: project, action: "sync", inserted_at: ~U[2018-01-03T00:00:00.000000Z]})
      _ = Repo.insert!(%Operation{project: project, action: "sync", inserted_at: ~U[2018-01-01T00:00:00.000000Z]})

      query = Scope.parse_added_last_sync(Translation, true, project.id, nil)

      assert inspect(query) ===
               "#Ecto.Query<from t0 in Accent.Translation, join: o1 in assoc(t0, :operations), where: o1.batch_operation_id == ^\"#{sync.id}\">"
    end

    test "no syncs", %{project: project} do
      query = Scope.parse_added_last_sync(Translation, true, project.id, nil)
      assert query === Translation
    end
  end
end
