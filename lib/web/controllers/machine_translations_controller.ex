defmodule Accent.MachineTranslationsController do
  use Phoenix.Controller

  import Canary.Plugs

  alias Accent.Document
  alias Accent.Language
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Scopes.Revision, as: RevisionScope
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Translation

  plug(Plug.Assign, %{canary_action: :machine_translations_translate})
  plug(:load_and_authorize_resource, model: Project, id_name: "project_id")
  plug(:fetch_master_revision)
  plug(:load_resource, model: Language, id_name: "language", as: :source_language)
  plug(:load_resource, model: Language, id_name: "to_language_id", as: :target_language)
  plug(:fetch_document when action === :translate_document)
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
      |> Translation.maybe_natural_order_by(conn.assigns[:order])
      |> Enum.map(&Translation.to_langue_entry(&1, nil, true, conn.assigns[:source_language].slug))

    case Accent.MachineTranslations.translate(
           entries,
           conn.assigns[:source_language].slug,
           conn.assigns[:target_language].slug,
           conn.assigns[:project].machine_translations_config
         ) do
      entries when is_list(entries) ->
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

      {:error, error} when is_atom(error) ->
        conn
        |> put_resp_header("content-type", "text/plain")
        |> send_resp(:unprocessable_entity, to_string(error))
    end
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
      Accent.MachineTranslations.translate(
        conn.assigns[:movement_context].entries,
        conn.assigns[:source_language].slug,
        conn.assigns[:target_language].slug,
        conn.assigns[:project].machine_translations_config
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

  defp fetch_format(%{params: %{"document_format" => format}} = conn, _) do
    assign(conn, :document_format, String.downcase(format))
  end

  defp fetch_format(conn, _) do
    assign(conn, :document_format, conn.assigns[:document].format)
  end

  defp fetch_document(conn, _) do
    assign(conn, :document, Repo.get(Document, conn.params["document_id"]))
  end

  defp fetch_order(%{params: %{"order_by" => ""}} = conn, _), do: assign(conn, :order, "index")
  defp fetch_order(%{params: %{"order_by" => order}} = conn, _), do: assign(conn, :order, order)
  defp fetch_order(conn, _), do: assign(conn, :order, "index")

  defp fetch_master_revision(%{assigns: %{project: project}} = conn, _) do
    revision =
      project
      |> Ecto.assoc(:revisions)
      |> RevisionScope.master()
      |> Repo.one()
      |> Repo.preload(:language)

    assign(conn, :master_revision, revision)
  end
end
