defmodule Accent.MachineTranslationsController do
  use Phoenix.Controller

  import Canary.Plugs

  alias Accent.{Document, Language, Project, Repo, Translation}
  alias Accent.Scopes.Revision, as: RevisionScope
  alias Accent.Scopes.Translation, as: TranslationScope

  plug(Plug.Assign, %{canary_action: :machine_translations_translate_file} when action === :translate_file)
  plug(Plug.Assign, %{canary_action: :machine_translations_translate_document} when action === :translate_document)
  plug(:load_and_authorize_resource, model: Project, id_name: "project_id")
  plug(:fetch_master_revision)
  plug(:load_resource, model: Language, id_name: "language", as: :source_language)
  plug(:load_resource, model: Language, id_name: "to_language_id", as: :target_language)
  plug(:load_resource, model: Document, id_name: "document_id", as: :document, only: [:machine_translations_translate_document])
  plug(:fetch_order when action === :translate_document)
  plug(:fetch_format when action === :translate_document)
  plug(Accent.Plugs.MovementContextParser when action === :translate_file)

  @doc """
  Translate a document from a language to another language.

  ## Endpoint

    POST /machine-translations/translate-document

  ### Required params
    - `project_id`
    - `from_language_id`
    - `to_language_id`
    - `document_id`
    - `document_format`

  ### Response

    #### Success
    `200` - A file containing the rendered document.

    #### Error
    `404` - Unknown project, language or format
  """
  def translate_document(conn, _params) do
    document = Map.put(conn.assigns[:document], :format, conn.assigns[:document_format])

    entries =
      Translation
      |> TranslationScope.active()
      |> TranslationScope.from_document(document.id)
      |> TranslationScope.from_language(conn.assigns[:source_language].id)
      |> TranslationScope.from_version(nil)
      |> TranslationScope.parse_order(conn.assigns[:order])
      |> Repo.all()
      |> Enum.map(&Translation.to_langue_entry(&1, nil, true, conn.assigns[:source_language].slug))

    entries =
      Accent.MachineTranslations.translate_entries(
        entries,
        conn.assigns[:source_language],
        conn.assigns[:target_language]
      )

    %{render: render} =
      Accent.TranslationsRenderer.render_entries(%{
        entries: entries,
        language: conn.assigns[:target_language],
        master_language: Accent.Revision.language(conn.assigns[:master_revision]),
        document: document
      })

    conn
    |> put_resp_header("content-type", "text/plain")
    |> send_resp(:ok, render)
  end

  @doc """
  Translate a file from a language to another language.

  ## Endpoint

    POST /machine-translations/translate-file

  ### Required params
    - `project_id`
    - `from_language_id`
    - `to_language_id`
    - `file`
    - `document_format`

  ### Response

    #### Success
    `200` - A file containing the rendered document.

    #### Error
    `404` - Unknown project, language or format
  """
  def translate_file(conn, _params) do
    entries =
      Accent.MachineTranslations.translate_entries(
        conn.assigns[:movement_context].entries,
        conn.assigns[:source_language],
        conn.assigns[:target_language]
      )

    %{render: render} =
      Accent.TranslationsRenderer.render_entries(%{
        entries: entries,
        language: conn.assigns[:target_language],
        master_language: Accent.Revision.language(conn.assigns[:master_revision]),
        document: conn.assigns[:movement_context].assigns[:document]
      })

    conn
    |> put_resp_header("content-type", "text/plain")
    |> send_resp(:ok, render)
  end

  defp fetch_format(conn = %{params: %{"document_format" => format}}, _) do
    assign(conn, :document_format, String.downcase(format))
  end

  defp fetch_format(conn, _) do
    assign(conn, :document_format, conn.assigns[:document].format)
  end

  defp fetch_order(conn = %{params: %{"order_by" => ""}}, _), do: assign(conn, :order, "index")
  defp fetch_order(conn = %{params: %{"order_by" => order}}, _), do: assign(conn, :order, order)
  defp fetch_order(conn, _), do: assign(conn, :order, "index")

  defp fetch_master_revision(conn = %{assigns: %{project: project}}, _) do
    revision =
      project
      |> Ecto.assoc(:revisions)
      |> RevisionScope.master()
      |> Repo.one()
      |> Repo.preload(:language)

    assign(conn, :master_revision, revision)
  end
end
