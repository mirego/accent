defmodule Accent.MergeController do
  use Plug.Builder

  import Canary.Plugs
  import Accent.Plugs.RevisionIdFromProjectLanguage

  alias Movement.Builders.RevisionMerge, as: RevisionMergeBuilder
  alias Movement.Persisters.RevisionMerge, as: RevisionMergePersister
  alias Movement.Comparers.{MergeSmart, MergeForce, MergePassive}

  alias Accent.{
    Project,
    Language,
    Revision
  }

  alias Accent.Hook.Context, as: HookContext

  plug(Plug.Assign, canary_action: :merge)
  plug(:load_and_authorize_resource, model: Project, id_name: "project_id")
  plug(Accent.Plugs.EnsureUnlockedFileOperations)
  plug(:load_resource, model: Language, id_name: "language", id_field: "slug")
  plug(:fetch_revision_id_from_project_language)
  plug(:load_and_authorize_resource, model: Revision, id_name: "revision_id", preload: :language)
  plug(Accent.Plugs.MovementContextParser)
  plug(:assign_comparer)
  plug(:create)

  @broadcaster Application.get_env(:accent, :hook_broadcaster)

  @doc """
  Create new merge for a project and a language

  ## Endpoint

    GET /merge

  ### Required params
    - `project_id`
    - `language_id`
    - `file`

  ### Optional params
    - `merge_type` (smart, force or passive), default: smart.

  ### Response

    #### Success
    `200` - Ok.

    #### Error
    `404` - Unknown revision
    `422` - Invalid file
  """
  def create(conn, _params) do
    conn.assigns[:movement_context]
    |> Movement.Context.assign(:revision, conn.assigns[:revision])
    |> Movement.Context.assign(:merge_type, conn.assigns[:merge_type])
    |> Movement.Context.assign(:user_id, conn.assigns[:current_user].id)
    |> RevisionMergeBuilder.build()
    |> RevisionMergePersister.persist()
    |> case do
      {:ok, {_context, []}} ->
        send_resp(conn, :ok, "")

      {:ok, _} ->
        @broadcaster.fanout(%HookContext{
          event: "merge",
          project: conn.assigns[:project],
          user: conn.assigns[:current_user],
          payload: %{
            merge_type: conn.assigns[:merge_type],
            language_name: conn.assigns[:revision].language.name
          }
        })

        send_resp(conn, :ok, "")

      {:error, _reason} ->
        send_resp(conn, :unprocessable_entity, "")
    end
  end

  defp assign_comparer(conn = %{params: %{"merge_type" => "force"}}, _) do
    context =
      conn.assigns[:movement_context]
      |> Movement.Context.assign(:comparer, &MergeForce.compare/2)

    assign(conn, :movement_context, context)
  end

  defp assign_comparer(conn = %{params: %{"merge_type" => "passive"}}, _) do
    context =
      conn.assigns[:movement_context]
      |> Movement.Context.assign(:comparer, &MergePassive.compare/2)

    assign(conn, :movement_context, context)
  end

  defp assign_comparer(conn, _) do
    context =
      conn.assigns[:movement_context]
      |> Movement.Context.assign(:comparer, &MergeSmart.compare/2)

    assign(conn, :movement_context, context)
  end
end
