defmodule Accent.Plugs.AssignCurrentUser do
  import Plug.Conn

  alias Accent.UserAuthFetcher

  def init(_), do: nil

  @doc """
  Takes a Plug.Conn and fetch the associated user giving the Authorization header.
  It assigns nil if any of the steps fails.
  """
  def call(conn, _opts) do
    user =
      conn
      |> get_req_header("authorization")
      |> Enum.at(0)
      |> UserAuthFetcher.fetch()

    assign(conn, :current_user, user)
  end
end
