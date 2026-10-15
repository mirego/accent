defmodule Accent.Plugs.AssignDocumentByPath do
  @moduledoc false
  import Plug.Conn

  alias Accent.Document
  alias Accent.Repo
  alias Accent.Scopes.Document, as: DocumentScope

  def init(opts), do: Keyword.get(opts, :required, false)

  def call(%{params: %{"document_path" => path} = params, assigns: %{project: project}} = conn, _required)
      when is_binary(path) do
    Document
    |> DocumentScope.from_project(project.id)
    |> DocumentScope.from_path(path)
    |> Repo.one()
    |> case do
      %Document{} = document -> assign(conn, :document, %{document | format: params["document_format"]})
      nil -> Accent.ErrorController.handle_not_found(conn)
    end
  end

  def call(conn, true), do: Accent.ErrorController.handle_not_found(conn)
  def call(conn, false), do: assign(conn, :document, nil)
end
