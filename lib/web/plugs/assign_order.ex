defmodule Accent.Plugs.AssignOrder do
  @moduledoc false
  import Plug.Conn

  @default_order "index"

  def init(_), do: nil

  def call(%{params: %{"order_by" => order}} = conn, _) when order not in [nil, ""], do: assign(conn, :order, order)
  def call(conn, _), do: assign(conn, :order, @default_order)
end
