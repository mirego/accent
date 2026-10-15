defmodule Accent.Plugs.AssignMasterRevision do
  @moduledoc false
  import Plug.Conn

  alias Accent.Repo
  alias Accent.Scopes.Revision, as: RevisionScope

  def init(_), do: nil

  def call(%{assigns: %{project: project}} = conn, _) do
    revision =
      project
      |> Ecto.assoc(:revisions)
      |> RevisionScope.master()
      |> Repo.one()
      |> Repo.preload(:language)

    assign(conn, :master_revision, revision)
  end
end
