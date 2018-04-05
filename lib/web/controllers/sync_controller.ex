defmodule Accent.SyncController do
  use Plug.Builder

  import Canary.Plugs

  alias Movement.Builders.ProjectSync, as: SyncBuilder
  alias Movement.Persisters.ProjectSync, as: SyncPersister
  alias Movement.Comparers.Sync, as: SyncComparer
  alias Accent.Project
  alias Accent.Hook.Context, as: HookContext

  plug(Plug.Assign, canary_action: :sync)
  plug(:load_and_authorize_resource, model: Project, id_name: "project_id")
  plug(Accent.Plugs.EnsureUnlockedFileOperations)
  plug(Accent.Plugs.MovementContextParser)
  plug(:assign_comparer)
  plug(:create)

  @broadcaster Application.get_env(:accent, :hook_broadcaster)

  @doc """
  Create new sync for a project

  ## Endpoint

    GET /sync

  ### Required params
    - `project_id`
    - `file`
    - `document_path`
    - `document_format`

  ### Response

    #### Success
    `200` - Ok.

    #### Error
    `404` - Unknown project
  """
  def create(conn, _) do
    conn.assigns[:movement_context]
    |> Movement.Context.assign(:project, conn.assigns[:project])
    |> Movement.Context.assign(:user_id, conn.assigns[:current_user].id)
    |> SyncBuilder.build()
    |> SyncPersister.persist()
    |> case do
      {:ok, {_context, []}} ->
        send_resp(conn, :ok, "")

      {:ok, {context, _operations}} ->
        @broadcaster.fanout(%HookContext{
          event: "sync",
          project: conn.assigns[:project],
          user: conn.assigns[:current_user],
          payload: %{
            batch_operation_stats: context.assigns[:batch_operation].stats,
            document_path: context.assigns[:document].path
          }
        })

        send_resp(conn, :ok, "")

      {:error, _reason} ->
        send_resp(conn, :unprocessable_entity, "")
    end
  end

  defp assign_comparer(conn, _) do
    context =
      conn.assigns[:movement_context]
      |> Movement.Context.assign(:comparer, &SyncComparer.compare/2)

    assign(conn, :movement_context, context)
  end
end
