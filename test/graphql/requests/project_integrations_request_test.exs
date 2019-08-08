defmodule AccentTest.GraphQL.Requests.ProjectIntegrations do
  use Accent.RepoCase

  alias Accent.{
    Collaborator,
    Integration,
    Project,
    Repo,
    User
  }

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    project = %Project{main_color: "#f00", name: "My project", last_synced_at: DateTime.from_naive!(~N[2017-01-01T00:00:00], "Etc/UTC")} |> Repo.insert!()
    user = %{user | permissions: %{project.id => "admin"}}

    %Collaborator{project_id: project.id, user_id: user.id, role: "admin"} |> Repo.insert!()

    create_mutation = """
      mutation IntegrationCreate(
        $events: [ProjectIntegrationEvent!],
        $service: ProjectIntegrationService!,
        $projectId: ID!,
        $data: ProjectIntegrationDataInput!
      ) {
        createProjectIntegration(
          events: $events,
          service: $service,
          projectId: $projectId,
          data: $data
        ) {
          result {
            id
          }

          successful
          messages {
            code
            field
          }
        }
      }
    """

    {:ok, [user: user, project: project, create_mutation: create_mutation]}
  end

  test "create integration successfully", %{user: user, project: project, create_mutation: mutation} do
    variables = %{
      "service" => "GITHUB",
      "projectId" => project.id,
      "data" => %{
        "repository" => "foo/bar",
        "token" => "1234",
        "defaultRef" => "master"
      }
    }

    {:ok, data} =
      Absinthe.run(
        mutation,
        Accent.GraphQL.Schema,
        variables: variables,
        context: %{conn: %Plug.Conn{assigns: %{current_user: user}}}
      )

    [integration] = Repo.all(Integration)
    assert get_in(data, [:data, "createProjectIntegration", "successful"]) === true
    assert get_in(data, [:data, "createProjectIntegration", "result", "id"]) === integration.id
  end

  test "create integration with errors", %{user: user, project: project, create_mutation: mutation} do
    variables = %{
      "service" => "GITHUB",
      "projectId" => project.id,
      "data" => %{
        "repository" => "",
        "token" => "",
        "defaultRef" => ""
      }
    }

    {:ok, data} =
      Absinthe.run(
        mutation,
        Accent.GraphQL.Schema,
        variables: variables,
        context: %{conn: %Plug.Conn{assigns: %{current_user: user}}}
      )

    assert Repo.all(Integration) == []
    assert get_in(data, [:data, "createProjectIntegration", "successful"]) === false

    assert get_in(data, [:data, "createProjectIntegration", "messages"]) === [
             %{"code" => "required", "field" => "data.defaultRef"},
             %{"code" => "required", "field" => "data.repository"},
             %{"code" => "required", "field" => "data.token"}
           ]
  end
end
