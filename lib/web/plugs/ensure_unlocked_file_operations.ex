defmodule Accent.Plugs.EnsureUnlockedFileOperations do
  import Plug.Conn

  def init(_), do: nil

  def call(conn, _) do
    if conn.assigns[:project].locked_file_operations do
      conn |> send_resp(:forbidden, "File operations are locked") |> halt
    else
      conn
    end
  end
end
