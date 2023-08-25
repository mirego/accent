defmodule Accent.Plugs.EnsureUnlockedFileOperations do
  @moduledoc false
  import Plug.Conn

  def init(_), do: nil

  def call(%{assigns: %{project: %{locked_file_operations: true}}} = conn, _) do
    conn
    |> send_resp(:forbidden, "File operations are locked")
    |> halt()
  end

  def call(conn, _), do: conn
end
