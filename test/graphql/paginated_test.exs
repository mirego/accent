defmodule AccentTest.GraphQL.Paginated do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Collaborator
  alias Accent.Project
  alias Accent.User
  alias Accent.Version

  setup do
    user = Factory.insert(User)
    project = Factory.insert(Project)
    user = %{user | permissions: %{project.id => "owner"}}

    Factory.insert(Collaborator, project_id: project.id, user_id: user.id, role: "owner")

    for i <- 1..3 do
      Factory.insert(Version,
        project_id: project.id,
        user_id: user.id,
        name: "v#{i}",
        tag: "v#{i}",
        inserted_at: DateTime.shift(~U[2020-01-01 00:00:00.000000Z], day: i)
      )
    end

    {:ok, [user: user, project: project]}
  end

  defp run(query, %{user: user, project: project}) do
    handler_id = {__MODULE__, make_ref()}
    test_pid = self()

    :telemetry.attach(
      handler_id,
      [:accent, :repo, :query],
      fn _, _, metadata, _ ->
        if self() == test_pid or test_pid in Process.get(:"$callers", []) do
          send(test_pid, {:sql, metadata.query})
        end
      end,
      nil
    )

    {:ok, %{data: data}} =
      Absinthe.run(query, Accent.GraphQL.Schema,
        variables: %{"projectId" => project.id},
        context: %{conn: %Plug.Conn{assigns: %{current_user: user}}}
      )

    :telemetry.detach(handler_id)

    {data["viewer"]["project"]["versions"], collect_sql([])}
  end

  defp collect_sql(acc) do
    receive do
      {:sql, query} -> collect_sql([query | acc])
    after
      0 -> Enum.reverse(acc)
    end
  end

  defp count_queries(sql), do: Enum.count(sql, &(&1 =~ "count("))

  test "entries without meta skip count query", context do
    {versions, sql} =
      run(
        "query($projectId: ID!) { viewer { project(id: $projectId) { versions(pageSize: 2) { entries { tag } } } } }",
        context
      )

    assert Enum.map(versions["entries"], & &1["tag"]) == ["v3", "v2"]
    assert count_queries(sql) == 0
  end

  test "entries without meta on second page", context do
    {versions, _sql} =
      run(
        "query($projectId: ID!) { viewer { project(id: $projectId) { versions(pageSize: 2, page: 2) { entries { tag } } } } }",
        context
      )

    assert Enum.map(versions["entries"], & &1["tag"]) == ["v1"]
  end

  test "entries without meta past last page clamp to last page", context do
    {versions, _sql} =
      run(
        "query($projectId: ID!) { viewer { project(id: $projectId) { versions(pageSize: 2, page: 5) { entries { tag } } } } }",
        context
      )

    assert Enum.map(versions["entries"], & &1["tag"]) == ["v1"]
  end

  test "meta requested runs count query", context do
    {versions, sql} =
      run(
        "query($projectId: ID!) { viewer { project(id: $projectId) { versions(pageSize: 2) { meta { totalEntries totalPages nextPage } entries { tag } } } } }",
        context
      )

    assert versions["meta"] == %{"totalEntries" => 3, "totalPages" => 2, "nextPage" => 2}
    assert count_queries(sql) == 1
  end
end
