defmodule Accent.LintController do
  use Phoenix.Controller

  import Canary.Plugs

  alias Accent.Project
  alias Accent.Repo
  alias Accent.Scopes.Revision, as: RevisionScope
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Translation
  alias Movement.Context

  plug(Plug.Assign, canary_action: :sync)
  plug(:load_and_authorize_resource, model: Project, id_name: "project_id")
  plug(Accent.Plugs.AssignRevisionLanguage)
  plug(Accent.Plugs.MovementContextParser)
  plug(:assign_context)
  plug(:assign_master_revision)
  plug(:assign_master_translations)
  plug(:assign_translations)

  @doc """
  Fetch linting errors for a file in a project

  ## Endpoint

    POST /lint

  ### Required params
    - `project_id`
    - `file`
    - `document_path`
    - `document_format`

  ### Response

    #### Success
    `200` - Ok.

    #### Error
    `404` - Unknown project
  """
  def lint(conn, _) do
    lint_translations =
      conn.assigns[:context].entries
      |> Enum.map(&map_entry(&1, conn))
      |> Accent.Lint.lint()
      |> map_lint_translations()

    render(conn, "index.json", lint_translations: lint_translations)
  end

  defp map_entry(entry, conn) do
    translation = Map.get(conn.assigns[:translations], {entry.key, conn.assigns[:document].id})

    master_translation =
      Map.get(conn.assigns[:master_translations], {entry.key, conn.assigns[:document].id}, translation)

    language_slug = conn.assigns[:revision].slug || conn.assigns[:revision].language.slug

    if translation do
      translation_entry =
        Translation.to_langue_entry(translation, master_translation, translation.revision.master, language_slug)

      %{
        translation_entry
        | value: entry.value,
          comment: entry.comment,
          index: entry.index,
          value_type: entry.value_type
      }
    else
      %{
        entry
        | id: nil,
          master_value: entry.value,
          language_slug: language_slug,
          is_master: conn.assigns[:revision].id === conn.assigns[:master_revision].id
      }
    end
  end

  defp assign_context(conn, _) do
    context =
      conn.assigns[:movement_context]
      |> Context.assign(:project, conn.assigns[:project])
      |> Context.assign(:revision, conn.assigns[:revision])
      |> Context.assign(:user_id, conn.assigns[:current_user].id)

    conn
    |> assign(:context, context)
    |> assign(:document, context.assigns[:document])
  end

  defp map_lint_translations(entries) do
    entries
    |> Enum.filter(&Enum.any?(elem(&1, 1)))
    |> Enum.map(fn {entry, messages} ->
      %Accent.TranslationLint{
        id: entry.id,
        entry: entry,
        translation_id: entry.id,
        messages: messages
      }
    end)
    |> Repo.preload(translation: [revision: :language])
  end

  defp assign_translations(conn, _) do
    translations =
      Translation
      |> base_translations(conn)
      |> TranslationScope.from_revision(conn.assigns[:revision].id)
      |> Repo.all()
      |> Repo.preload([:revision, :document])
      |> Map.new(&{{&1.key, &1.document_id}, &1})

    assign(conn, :translations, translations)
  end

  defp assign_master_translations(conn, _) do
    master_translations =
      Translation
      |> base_translations(conn)
      |> TranslationScope.from_revision(conn.assigns[:master_revision].id)
      |> Repo.all()
      |> Map.new(&{{&1.key, &1.document_id}, &1})

    assign(conn, :master_translations, master_translations)
  end

  defp assign_master_revision(conn, _) do
    master_revision =
      conn.assigns[:project]
      |> Ecto.assoc(:revisions)
      |> RevisionScope.master()
      |> Repo.one()
      |> Repo.preload(:language)

    assign(conn, :master_revision, master_revision)
  end

  defp base_translations(query, conn) do
    query
    |> TranslationScope.from_project(conn.assigns[:project].id)
    |> TranslationScope.from_document(conn.assigns[:document].id)
    |> TranslationScope.from_version(nil)
    |> TranslationScope.active()
    |> TranslationScope.not_locked()
  end
end
