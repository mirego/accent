defmodule Accent.ExportJIPTController do
  use Plug.Builder

  import Canary.Plugs

  alias Accent.Project
  alias Accent.Repo
  alias Accent.Scopes.Translation, as: Scope
  alias Accent.Translation

  plug(Plug.Assign, %{canary_action: :export_revision})
  plug(:load_resource, model: Project, id_name: "project_id")

  plug(Accent.Plugs.AssignVersion)
  plug(Accent.Plugs.AssignDocumentByPath, required: true)
  plug(Accent.Plugs.AssignMasterRevision)
  plug(:fetch_translations)
  plug(:fetch_rendered_document)

  plug(:index)

  @doc """
  Export a document to a file used in JIPT

  ## Endpoint

    GET /jipt-export

  ### Required params
    - `project_id`
    - `language`
    - `document_format`
    - `document_path`

  ### Response

    #### Success
    `200` - A file containing the rendered document.

    #### Error
    - `404` Unknown revision id.
  """
  def index(%{query_params: %{"inline_render" => "true"}} = conn, _) do
    conn
    |> put_resp_header("content-type", "text/plain")
    |> send_resp(:ok, conn.assigns[:document].render)
  end

  def index(conn, _) do
    file = Path.join([System.tmp_dir(), Accent.SecureRandom.urlsafe_base64(16)])

    :ok = File.write(file, conn.assigns[:document].render)

    conn
    |> put_resp_header("content-disposition", "inline; filename=\"#{conn.params["document_path"]}\"")
    |> send_file(:ok, file)
  end

  defp fetch_translations(
         %{assigns: %{document: document, version: version, master_revision: master_revision}} = conn,
         _
       ) do
    translations =
      Translation
      |> Scope.active()
      |> Scope.from_document(document.id)
      |> Scope.from_revision(master_revision.id)
      |> Scope.from_version(version && version.id)
      |> Scope.parse_order(nil)
      |> Repo.all()

    assign(conn, :translations, translations)
  end

  defp fetch_rendered_document(
         %{assigns: %{master_revision: master_revision, translations: translations, document: document}} = conn,
         _
       ) do
    language = Accent.Revision.language(master_revision)

    %{render: render} =
      Accent.TranslationsRenderer.render_translations(%{
        translations: translations,
        document: document,
        master_language: language,
        language: language,
        value_map: &"{^#{&1.key}@#{document.path}}"
      })

    document = Map.put(document, :render, render)

    assign(conn, :document, document)
  end
end
