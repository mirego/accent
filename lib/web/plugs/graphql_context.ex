defmodule Accent.Plugs.GraphQLContext do
  @moduledoc false
  @behaviour Plug

  import Plug.Conn

  @type t :: %{context: map()}

  def init(opts), do: opts

  def call(conn, _) do
    put_private(conn, :absinthe, %{context: %{conn: conn}})
  end
end
