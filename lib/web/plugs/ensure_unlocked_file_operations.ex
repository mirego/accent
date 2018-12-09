defmodule Accent.Plugs.EnsureUnlockedFileOperations do
  import Plug.Conn

  def init(_), do: nil

  def call(conn = %{assigns: %{project: %{locked_file_operations: true}}}, _) do
    conn
    |> send_resp(:forbidden, "File operations are locked")
    |> halt()
  end

  def call(conn, _), do: conn
end
