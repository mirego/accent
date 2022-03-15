defmodule AccentTest.Scopes.Translation do
  use Accent.RepoCase, async: true
  doctest Accent.Scopes.Translation

  alias Accent.{Document, Operation, Project, Repo, Translation}
  alias Accent.Scopes.Translation, as: Scope

  setup do
    project = %Project{main_color: "#f00", name: "My project"} |> Repo.insert!()

    {:ok, [project: project]}
  end

  describe "parse_added_last_sync/3" do
    test "existing sync", %{project: project} do
      sync = %Operation{project: project, action: "sync"} |> Repo.insert!()

      query = Scope.parse_added_last_sync(Translation, true, project.id, nil)
      assert inspect(query) === "#Ecto.Query<from t0 in Accent.Translation, join: o1 in assoc(t0, :operations), where: o1.batch_operation_id == ^\"#{sync.id}\">"
    end

    test "existing sync with document", %{project: project} do
      document = Repo.insert!(%Document{project_id: project.id, path: "my-test", format: "xliff_1_2"})
      sync = %Operation{project: project, action: "sync", document: document} |> Repo.insert!()
      _other_sync = %Operation{project: project, action: "sync"} |> Repo.insert!()

      query = Scope.parse_added_last_sync(Translation, true, project.id, document.id)
      assert inspect(query) === "#Ecto.Query<from t0 in Accent.Translation, join: o1 in assoc(t0, :operations), where: o1.batch_operation_id == ^\"#{sync.id}\">"
    end

    test "many sync", %{project: project} do
      _ = %Operation{project: project, action: "sync", inserted_at: ~U[2018-01-02T00:00:00.000000Z]} |> Repo.insert!()
      sync = %Operation{project: project, action: "sync", inserted_at: ~U[2018-01-03T00:00:00.000000Z]} |> Repo.insert!()
      _ = %Operation{project: project, action: "sync", inserted_at: ~U[2018-01-01T00:00:00.000000Z]} |> Repo.insert!()

      query = Scope.parse_added_last_sync(Translation, true, project.id, nil)
      assert inspect(query) === "#Ecto.Query<from t0 in Accent.Translation, join: o1 in assoc(t0, :operations), where: o1.batch_operation_id == ^\"#{sync.id}\">"
    end

    test "no syncs", %{project: project} do
      query = Scope.parse_added_last_sync(Translation, true, project.id, nil)
      assert query === Translation
    end
  end
end
