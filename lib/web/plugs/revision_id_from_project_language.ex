defmodule Accent.Plugs.RevisionIdFromProjectLanguage do
  import Plug.Conn

  alias Accent.{Repo, Revision}

  def fetch_revision_id_from_project_language(conn = %{assigns: %{language: language, project: project}}, _) do
    Revision
    |> Repo.get_by(language_id: language.id, project_id: project.id)
    |> case do
      %Revision{id: id} ->
        put_in(conn, [Access.key(:params, %{}), "revision_id"], id)

      nil ->
        conn
        |> send_resp(:not_found, "")
        |> halt()
    end
  end
end
