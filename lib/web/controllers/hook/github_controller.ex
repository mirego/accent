defmodule Accent.Hook.GitHubController do
  use Plug.Builder

  import Canary.Plugs
  import Ecto.Query, only: [first: 1]

  alias Accent.Hook.Context, as: HookContext
  alias Accent.{Integration, Project, Repo}
  alias Accent.Scopes.Integration, as: IntegrationScope

  plug(Plug.Assign, canary_action: :hook_sync)
  plug(:load_and_authorize_resource, model: Project, id_name: "project_id")
  plug(:assign_payload)
  plug(:sync)

  def sync(conn, _) do
    Accent.Hook.external_document_update(:github, %HookContext{
      event: "push",
      payload: conn.assigns[:payload],
      project: conn.assigns[:project],
      user: conn.assigns[:current_user]
    })

    send_resp(conn, :no_content, "")
  end

  defp assign_payload(conn, _) do
    with repository when is_binary(repository) <- conn.params["repository"]["full_name"],
         ref when is_binary(ref) <- conn.params["ref"],
         %{data: %{token: token, default_ref: default_ref}} <- repository_integration(conn.assigns[:project], repository) do
      assign(conn, :payload, %{
        default_ref: default_ref,
        ref: ref,
        repository: repository,
        token: token
      })
    else
      _ ->
        conn
        |> send_resp(:no_content, "")
        |> halt()
    end
  end

  defp repository_integration(project, repository) do
    Integration
    |> IntegrationScope.from_project(project.id)
    |> IntegrationScope.from_service("github")
    |> IntegrationScope.from_data_repository(repository)
    |> first()
    |> Repo.one()
  end
end
