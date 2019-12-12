defmodule Accent.Plugs.AssignRevisionLanguage do
  use Plug.Builder

  alias Accent.{Language, Repo, Revision}

  def fetch_revision_id_from_project_language(conn, _) do
    conn
  end

  def call(conn, _) do
    conn
    |> maybe_add_language_from_revision()
    |> maybe_add_language_with_revision()
    |> assign_language_and_revision()
  end

  defp maybe_add_language_from_revision(conn = %{params: %{"language" => slug}, assigns: %{project: project}}) do
    revision = get_revision_by_slug(slug, project)

    if revision do
      {conn, revision, revision.language}
    else
      conn
    end
  end

  defp maybe_add_language_with_revision({conn, revision, language}), do: {conn, revision, language}

  defp maybe_add_language_with_revision(conn = %{params: %{"language" => slug}, assigns: %{project: project}}) do
    language = Repo.get_by(Language, slug: slug)
    revision = get_revision_by_language(language, project)

    if revision do
      {conn, revision, language}
    else
      conn
    end
  end

  defp assign_language_and_revision({conn, revision, language}) do
    conn
    |> assign(:language, language)
    |> assign(:revision, revision)
  end

  defp assign_language_and_revision(conn) do
    conn
    |> send_resp(:not_found, "")
    |> halt()
  end

  defp get_revision_by_slug(nil, _project) do
    nil
  end

  defp get_revision_by_slug(slug, project) do
    Revision
    |> Repo.get_by(slug: slug, project_id: project.id)
    |> Repo.preload(:language)
  end

  defp get_revision_by_language(nil, _project) do
    nil
  end

  defp get_revision_by_language(language, project) do
    Revision
    |> Repo.get_by(language_id: language.id, project_id: project.id)
    |> Repo.preload(:language)
  end
end
