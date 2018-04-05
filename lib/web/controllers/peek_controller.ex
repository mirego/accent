defmodule Accent.PeekController do
  use Phoenix.Controller

  import Canary.Plugs
  import Accent.Plugs.RevisionIdFromProjectLanguage

  alias Movement.Builders.ProjectSync, as: ProjectSyncBuilder
  alias Movement.Builders.RevisionMerge, as: RevisionMergeBuilder
  alias Movement.Comparers.Sync, as: SyncComparer
  alias Movement.Comparers.{MergeSmart, MergeForce, MergePassive}

  alias Accent.{
    Project,
    Revision,
    Language
  }

  alias Accent.Hook.Context, as: HookContext

  plug(Plug.Assign, [canary_action: :peek_merge] when action === :merge)
  plug(Plug.Assign, [canary_action: :peek_sync] when action === :sync)
  plug(:load_and_authorize_resource, model: Project, id_name: "project_id")
  plug(:load_resource, model: Language, id_name: "language", id_field: "slug")
  plug(:fetch_revision_id_from_project_language when action === :merge)
  plug(:load_and_authorize_resource, model: Revision, id_name: "revision_id", preload: :language, only: [:peek_merge])
  plug(Accent.Plugs.MovementContextParser)
  plug(:parse_merge_option when action in [:merge])

  @broadcaster Application.get_env(:accent, :hook_broadcaster)

  @doc """
  Peek operations that would be created when doing a sync

  ## Endpoint

    GET /sync/peek

  ### Required params
    - `project_id`
    - `language_id`
    - `file`
    - `document_path`
    - `document_format`

  ### Response

    #### Success
    `200` - List of serialized operations grouped in master_operations and slaves_operations keys

    #### Error
    `404` - Unknown project
  """
  def sync(conn, _params) do
    operations =
      conn.assigns[:movement_context]
      |> Movement.Context.assign(:project, conn.assigns[:project])
      |> Movement.Context.assign(:comparer, &SyncComparer.compare/2)
      |> ProjectSyncBuilder.build()
      |> Map.get(:operations)
      |> Enum.group_by(&Map.get(&1, :revision_id))

    @broadcaster.fanout(%HookContext{
      event: "peek_sync",
      project: conn.assigns[:project],
      user: conn.assigns[:current_user]
    })

    render(conn, "index.json", operations: operations)
  end

  @doc """
  Peek operations that would be created when doing a merge

  ## Endpoint

    GET /merge/peek

  ### Required params
    - `project_id`
    - `language_id`
    - `file`
    - `document_path`
    - `document_format`

  ### Optional params
    - `merge_type`

  ### Response

    #### Success
    `200` - List of serialized operations

    #### Error
    `404` - Unknown revision
    `422` - Invalid file
  """
  def merge(conn, _params) do
    operations =
      conn.assigns[:movement_context]
      |> Movement.Context.assign(:revision, conn.assigns[:revision])
      |> Movement.Context.assign(:merge_type, conn.assigns[:merge_type])
      |> RevisionMergeBuilder.build()
      |> Map.get(:operations)
      |> Enum.group_by(&Map.get(&1, :revision_id))

    @broadcaster.fanout(%HookContext{
      event: "peek_merge",
      project: conn.assigns[:project],
      user: conn.assigns[:current_user],
      payload: %{
        merge_type: conn.assigns[:merge_type],
        language_name: conn.assigns[:revision].language.name
      }
    })

    render(conn, "index.json", operations: operations)
  end

  defp parse_merge_option(conn = %{params: %{"merge_type" => "force"}}, _) do
    context =
      conn.assigns[:movement_context]
      |> Movement.Context.assign(:comparer, &MergeForce.compare/2)

    assign(conn, :movement_context, context)
  end

  defp parse_merge_option(conn = %{params: %{"merge_type" => "passive"}}, _) do
    context =
      conn.assigns[:movement_context]
      |> Movement.Context.assign(:comparer, &MergePassive.compare/2)

    assign(conn, :movement_context, context)
  end

  defp parse_merge_option(conn, _) do
    context =
      conn.assigns[:movement_context]
      |> Movement.Context.assign(:comparer, &MergeSmart.compare/2)

    assign(conn, :movement_context, context)
  end
end
