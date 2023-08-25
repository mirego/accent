defmodule Accent.ProjectChannel do
  @moduledoc false
  use Phoenix.Channel

  alias Accent.Project

  def join("projects:" <> project_id, _params, %{assigns: %{user: user}} = socket) do
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
