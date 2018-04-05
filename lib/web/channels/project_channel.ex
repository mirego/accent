defmodule Accent.ProjectChannel do
  use Phoenix.Channel

  alias Accent.Project

  import Canada, only: [can?: 2]

  def join("projects:" <> project_id, _params, socket) do
    if socket.assigns[:user] |> can?(show_project(%Project{id: project_id})) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end
end
