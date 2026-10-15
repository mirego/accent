defmodule Accent.ExportController do
  use Plug.Builder

  import Canary.Plugs

  alias Accent.Document
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Scopes.Translation, as: Scope
  alias Accent.Translation

  plug(Plug.Assign, %{canary_action: :export_revision})
  plug(:load_and_authorize_resource, model: Project, id_name: "project_id")
  plug(Accent.Plugs.AssignRevisionLanguage)

  plug(Accent.Plugs.AssignOrder)
  plug(Accent.Plugs.AssignDocumentByPath)
  plug(Accent.Plugs.AssignVersion)
  plug(:fetch_translations)
  plug(Accent.Plugs.AssignMasterRevision)
  plug(:fetch_master_translations)
  plug(:fetch_rendered_document)

  plug(:index)

  @doc """
  Export a revision to a file

  ## Endpoint

    GET /export

  ### Required params
    - `project_id`
    - `language`
    - `document_format`
    - `document_path`

  ### Optional params
    - `order_by`
    - `inline_render`
    - `version`
    - `filters`

  ### Response

    #### Success
    `200` - A file containing the rendered document.

    #### Error
    - `404` Unknown revision id.
  """
  def index(%{query_params: %{"inline_render" => "true"}} = conn, _) do
    :telemetry.execute([:accent, :export], %{count: 1}, %{
      format: conn.assigns[:document] && conn.assigns[:document].format
    })

    conn
    |> put_resp_header("content-type", "text/plain")
    |> send_resp(:ok, conn.assigns[:document].render)
  end

  def index(conn, _) do
    :telemetry.execute([:accent, :export], %{count: 1}, %{
      format: conn.assigns[:document] && conn.assigns[:document].format
    })

    file = Path.join([System.tmp_dir(), Accent.SecureRandom.urlsafe_base64(16)])

    :ok = File.write(file, conn.assigns[:document].render)

    conn
    |> put_resp_header("content-disposition", "inline; filename=\"#{conn.params["document_path"]}\"")
    |> send_file(:ok, file)
  end

  defp fetch_translations(
         %{assigns: %{document: document, order: order, revision: revision, version: version}} = conn,
         _
       ) do
    filters = parse_filters(conn.params["filters"])

    translations =
      Translation
      |> Scope.active()
      |> Scope.from_document((document && document.id) || :all)
      |> Scope.from_revision(revision.id)
      |> Scope.from_version(version && version.id)
      |> Scope.parse_order(order)
      |> Scope.parse_conflicted(filters[:is_conflicted])
      |> Scope.parse_added_last_sync(filters[:is_added_last_sync], revision.project_id, document && document.id)
      |> Scope.parse_empty(filters[:is_text_empty])
      |> Repo.all()
      |> Translation.maybe_natural_order_by(order)

    assign(conn, :translations, translations)
  end

  defp parse_filters(filters) when is_map(filters) do
    %{
      is_text_empty: if(filters["is_text_empty"] === "true", do: true),
      is_conflicted: if(filters["is_conflicted"] === "true", do: true),
      is_added_last_sync: if(filters["is_added_last_sync"] === "true", do: true)
    }
  end

  defp parse_filters(_), do: %{}

  defp fetch_master_translations(%{assigns: %{revision: %{master: true}, translations: translations}} = conn, _) do
    assign(conn, :master_translations, translations)
  end

  defp fetch_master_translations(
         %{assigns: %{document: document, version: version, master_revision: master_revision}} = conn,
         _
       ) do
    translations =
      Translation
      |> Scope.active()
      |> Scope.from_document((document && document.id) || :all)
      |> Scope.from_revision(master_revision.id)
      |> Scope.from_version(version && version.id)
      |> Repo.all()

    assign(conn, :master_translations, translations)
  end

  defp fetch_rendered_document(
         %{
           assigns: %{
             master_revision: master_revision,
             master_translations: master_translations,
             translations: translations,
             revision: revision,
             document: document
           }
         } = conn,
         _
       ) do
    document = document || %Document{format: conn.params["document_format"]}

    %{render: render} =
      Accent.TranslationsRenderer.render_translations(%{
        master_translations: master_translations,
        translations: translations,
        master_language: Accent.Revision.language(master_revision),
        language: Accent.Revision.language(revision),
        document: document
      })

    document = Map.put(document, :render, render)

    assign(conn, :document, document)
  end
end
