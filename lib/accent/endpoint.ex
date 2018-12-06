defmodule Accent.Endpoint do
  use Phoenix.Endpoint, otp_app: :accent

  socket("/socket", Accent.UserSocket, websocket: true)

  if Application.get_env(:accent, :force_ssl) do
    plug(Plug.SSL, rewrite_on: [:x_forwarded_proto])
  end

  plug(Corsica, origins: "*", allow_headers: ~w(Accept Content-Type Authorization origin))

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug(Plug.Static, at: "/static", from: "priv/static", gzip: false, only: ~w(images))
  plug(Plug.Static, at: "/", from: "priv/static/webapp", gzip: false, only: ~w(assets index.html))

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  if Application.get_env(:accent, :sql_sandbox) do
    plug(Phoenix.Ecto.SQL.Sandbox)
  end

  plug(Accent.Router)
end
