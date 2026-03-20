defmodule Accent.Plugs.Session do
  @moduledoc false
  @behaviour Plug

  @impl Plug
  def init(_opts), do: []

  @impl Plug
  def call(conn, _opts) do
    signing_salt = Application.get_env(:accent, Accent.Endpoint)[:signing_salt]

    opts =
      Plug.Session.init(
        store: :cookie,
        key: "accent",
        signing_salt: signing_salt
      )

    Plug.Session.call(conn, opts)
  end
end
