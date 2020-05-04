defmodule Accent.ExportController do
  use Plug.Builder

  import Canary.Plugs

  alias Accent.Scopes.Document, as: DocumentScope
  alias Accent.Scopes.Revision, as: RevisionScope
  alias Accent.Scopes.Translation, as: Scope
  alias Accent.Scopes.Version, as: VersionScope

  alias Accent.{
    Document,
    Project,
    Repo,
    Translation,
    Version
  }

  plug(Plug.Assign, %{canary_action: :export_revision})
  plug(:load_resource, model: Project, id_name: "project_id")
  plug(Accent.Plugs.AssignRevisionLanguage)

  plug(:fetch_order)
  plug(:fetch_document)
  plug(:fetch_version)
  plug(:fetch_translations)
  plug(:fetch_master_revision)
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

  ### Response

    #### Success
    `200` - A file containing the rendered document.

    #### Error
    - `404` Unknown revision id.
  """
  def index(conn = %{query_params: %{"inline_render" => "true"}}, _) do
    conn
    |> put_resp_header("content-type", "text/plain")
    |> send_resp(:ok, conn.assigns[:document].render)
  end

  def index(conn, _) do
    file =
      [
        System.tmp_dir(),
        Accent.Utils.SecureRandom.urlsafe_base64(16)
      ]
      |> Path.join()

    :ok = File.write(file, conn.assigns[:document].render)

    conn
    |> put_resp_header("content-disposition", "inline; filename=\"#{conn.params["document_path"]}\"")
    |> send_file(:ok, file)
  end

  defp fetch_order(conn = %{params: %{"order_by" => ""}}, _), do: assign(conn, :order, "index")
  defp fetch_order(conn = %{params: %{"order_by" => order}}, _), do: assign(conn, :order, order)
  defp fetch_order(conn, _), do: assign(conn, :order, "index")

  defp fetch_translations(conn = %{assigns: %{document: document, order: order, revision: revision, version: version}}, _) do
    translations =
      Translation
      |> Scope.active()
      |> Scope.from_document(document.id)
      |> Scope.from_revision(revision.id)
      |> Scope.from_version(version && version.id)
      |> Scope.parse_order(order)
      |> Repo.all()

    assign(conn, :translations, translations)
  end

  defp fetch_master_revision(conn = %{assigns: %{project: project}}, _) do
    revision =
      project
      |> Ecto.assoc(:revisions)
      |> RevisionScope.master()
      |> Repo.one()
      |> Repo.preload(:language)

    assign(conn, :master_revision, revision)
  end

  defp fetch_master_translations(conn = %{assigns: %{revision: %{master: true}, translations: translations}}, _) do
    assign(conn, :master_translations, translations)
  end

  defp fetch_master_translations(conn = %{assigns: %{document: document, version: version, master_revision: master_revision}}, _) do
    translations =
      Translation
      |> Scope.active()
      |> Scope.from_document(document.id)
      |> Scope.from_revision(master_revision.id)
      |> Scope.from_version(version && version.id)
      |> Repo.all()

    assign(conn, :master_translations, translations)
  end

  defp fetch_document(conn = %{params: params, assigns: %{project: project}}, _) do
    Document
    |> DocumentScope.from_project(project.id)
    |> DocumentScope.from_path(params["document_path"])
    |> Repo.one()
    |> case do
      document = %Document{} ->
        document = Map.put(document, :format, params["document_format"])
        assign(conn, :document, document)

      _ ->
        Accent.ErrorController.handle_not_found(conn)
    end
  end

  defp fetch_version(conn = %{params: %{"version" => version_param}, assigns: %{project: project}}, _) do
    Version
    |> VersionScope.from_project(project.id)
    |> VersionScope.from_tag(version_param)
    |> Repo.one()
    |> case do
      version = %Version{} ->
        assign(conn, :version, version)

      _ ->
        Accent.ErrorController.handle_not_found(conn)
    end
  end

  defp fetch_version(conn, _), do: assign(conn, :version, nil)

  defp fetch_rendered_document(
         conn = %{assigns: %{master_revision: master_revision, master_translations: master_translations, translations: translations, revision: revision, document: document}},
         _
       ) do
    %{render: render} =
      Accent.TranslationsRenderer.render(%{
        master_translations: master_translations,
        master_revision: master_revision,
        translations: translations,
        language: Accent.Revision.language(revision),
        document: document
      })

    document = Map.put(document, :render, render)

    assign(conn, :document, document)
  end
end
