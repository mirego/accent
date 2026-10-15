defmodule Accent.Plugs.AssignVersion do
  @moduledoc false
  import Plug.Conn

  alias Accent.Version
  alias Accent.VersionFinder

  def init(_), do: nil

  def call(%{params: %{"version" => tag}, assigns: %{project: project}} = conn, _) do
    case VersionFinder.find_by_tag(project.id, tag) do
      %Version{} = version -> assign(conn, :version, version)
      nil -> Accent.ErrorController.handle_not_found(conn)
    end
  end

  def call(conn, _), do: assign(conn, :version, nil)
end
