defmodule AccentTest.GraphQL.Requests.ProjectIntegrations do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Collaborator
  alias Accent.Integration
  alias Accent.Project
  alias Accent.Repo
  alias Accent.User

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)

    project =
      Repo.insert!(%Project{
        main_color: "#f00",
        name: "My project",
        last_synced_at: DateTime.from_naive!(~N[2017-01-01T00:00:00], "Etc/UTC")
      })

    user = %{user | permissions: %{project.id => "admin"}}

    Repo.insert!(%Collaborator{project_id: project.id, user_id: user.id, role: "admin"})

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
      "service" => "SLACK",
      "projectId" => project.id,
      "data" => %{
        "url" => "https://slack.com/hook?token=foo"
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
      "service" => "SLACK",
      "projectId" => project.id,
      "data" => %{
        "url" => ""
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

    validation_messages = get_in(data, [:data, "createProjectIntegration", "messages"])

    assert length(validation_messages) === 1

    assert %{"code" => "required", "field" => "data.url"} in validation_messages
  end
end
