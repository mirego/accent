defmodule Accent.Plugs.GraphQLContext do
  @behaviour Plug

  @type t :: %{context: map()}

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    conn
    |> put_private(:absinthe, %{context: %{conn: conn}})
  end
end
