defmodule Accent.SyncController do
  use Plug.Builder

  import Canary.Plugs

  alias Accent.Project
  alias Movement.Builders.ProjectSync, as: SyncBuilder
  alias Movement.Context
  alias Movement.Persisters.ProjectSync, as: SyncPersister

  plug(Plug.Assign, canary_action: :sync)
  plug(:load_and_authorize_resource, model: Project, id_name: "project_id")
  plug(Accent.Plugs.EnsureUnlockedFileOperations)
  plug(Accent.Plugs.MovementContextParser)
  plug(:assign_comparer)
  plug(:create)

  @doc """
  Create new sync for a project

  ## Endpoint

    GET /sync

  ### Required params
    - `project_id`
    - `file`
    - `document_path`
    - `document_format`
  ### Optional params

    - `sync_type` (smart or passive), default: smart.

  ### Response

    #### Success
    `200` - Ok.

    #### Error
    `404` - Unknown project
  """
  def create(conn, _) do
    conn.assigns[:movement_context]
    |> Context.assign(:project, conn.assigns[:project])
    |> Context.assign(:user_id, conn.assigns[:current_user].id)
    |> SyncBuilder.build()
    |> SyncPersister.persist()
    |> case do
      {:ok, {_context, _}} ->
        send_resp(conn, :ok, "")

      {:error, _reason} ->
        send_resp(conn, :unprocessable_entity, "")
    end
  end

  defp assign_comparer(conn, _) do
    comparer = Movement.Comparer.comparer(:sync, conn.params["sync_type"])
    context = Context.assign(conn.assigns[:movement_context], :comparer, comparer)

    assign(conn, :movement_context, context)
  end
end
