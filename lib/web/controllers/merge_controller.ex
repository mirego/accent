defmodule Accent.MergeController do
  use Plug.Builder

  import Canary.Plugs

  alias Accent.Project
  alias Movement.Builders.RevisionMerge, as: RevisionMergeBuilder
  alias Movement.Context
  alias Movement.Persisters.RevisionMerge, as: RevisionMergePersister

  plug(Plug.Assign, canary_action: :merge)
  plug(:load_and_authorize_resource, model: Project, id_name: "project_id")
  plug(Accent.Plugs.EnsureUnlockedFileOperations)
  plug(Accent.Plugs.AssignRevisionLanguage)
  plug(Accent.Plugs.MovementContextParser)
  plug(:assign_comparer)
  plug(:assign_merge_options)
  plug(:create)

  @doc """
  Create new merge for a project and a language

  ## Endpoint

    GET /add-translations

  ### Required params
    - `project_id`
    - `language_id`
    - `file`

  ### Optional params
    - `merge_type` (smart, force or passive), default: smart.
    - `merge_options`

  ### Response

    #### Success
    `200` - Ok.

    #### Error
    `404` - Unknown revision
    `422` - Invalid file
  """
  def create(conn, _params) do
    conn.assigns[:movement_context]
    |> Context.assign(:revision, conn.assigns[:revision])
    |> Context.assign(:merge_type, conn.assigns[:merge_type])
    |> Context.assign(:merge_options, conn.assigns[:merge_options])
    |> Context.assign(:user_id, conn.assigns[:current_user].id)
    |> RevisionMergeBuilder.build()
    |> RevisionMergePersister.persist()
    |> case do
      {:ok, {_context, _}} ->
        :telemetry.execute([:accent, :merge], %{count: 1}, %{format: conn.assigns[:document_format]})
        send_resp(conn, :ok, "")

      {:error, _reason} ->
        send_resp(conn, :unprocessable_entity, "")
    end
  end

  defp assign_comparer(conn, _) do
    comparer = Movement.Comparer.comparer(:merge, conn.params["merge_type"])
    context = Context.assign(conn.assigns[:movement_context], :comparer, comparer)

    assign(conn, :movement_context, context)
  end

  defp assign_merge_options(conn, _) do
    options =
      case conn.params["merge_options"] do
        options when is_binary(options) -> Enum.reject(String.split(options, ","), &(&1 in ["", nil]))
        _ -> []
      end

    assign(conn, :merge_options, options ++ git_branch_options(conn.params["git_branch"]))
  end

  defp git_branch_options(git_branch) when is_binary(git_branch) and git_branch !== "", do: ["git_branch:#{git_branch}"]

  defp git_branch_options(_), do: []
end
