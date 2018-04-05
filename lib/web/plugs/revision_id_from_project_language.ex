defmodule Accent.Plugs.RevisionIdFromProjectLanguage do
  alias Accent.Repo
  alias Accent.Revision

  def fetch_revision_id_from_project_language(conn = %{assigns: %{language: language, project: project}}, _) do
    case Repo.get_by(Revision, language_id: language.id, project_id: project.id) do
      %Revision{id: id} ->
        %{conn | params: Map.put(conn.params, "revision_id", id)}

      nil ->
        conn
        |> Plug.Conn.send_resp(:not_found, "")
        |> Plug.Conn.halt()
    end
  end
end
