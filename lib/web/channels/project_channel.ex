defmodule Accent.ProjectChannel do
  use Phoenix.Channel

  alias Accent.Project

  def join("projects:" <> project_id, _params, socket = %{assigns: %{user: user}}) do
    if Canada.Can.can?(user, :show_project, %Project{id: project_id}) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def join(_, _, _) do
    {:error, %{reason: "unauthorized"}}
  end
end
