defmodule Accent.MachineTranslationsController do
  use Phoenix.Controller

  import Canary.Plugs

  alias Accent.{Language, Project, Repo}
  alias Accent.Scopes.Revision, as: RevisionScope

  plug(Plug.Assign, canary_action: :machine_translations_translate_file)
  plug(:load_and_authorize_resource, model: Project, id_name: "project_id")
  plug(:load_resource, model: Language, id_name: "language", as: :source_language)
  plug(:load_resource, model: Language, id_name: "to_language_id", as: :target_language)
  plug(Accent.Plugs.MovementContextParser)
  plug(:fetch_master_revision)

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
