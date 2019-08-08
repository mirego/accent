defmodule Accent.Endpoint do
  use Phoenix.Endpoint, otp_app: :accent

  socket("/socket", Accent.UserSocket, websocket: true)

  plug(:force_ssl)
  plug(Corsica, origins: "*", allow_headers: ~w(Accept Content-Type Authorization origin))

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug(Plug.Static, at: "/static", from: {:accent, "priv/static"}, gzip: true, only: ~w(jipt images))
  plug(Plug.Static, at: "/", from: {:accent, "priv/static/webapp"}, gzip: true, only: ~w(favicon.ico assets index.html robot.txt))

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket, websocket: true)
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

  plug(Accent.Router)

  defp force_ssl(conn, _opts) do
    if Application.get_env(:accent, :force_ssl) do
      opts = Plug.SSL.init(rewrite_on: [:x_forwarded_proto])

      Plug.SSL.call(conn, opts)
    else
      conn
    end
  end

  @doc """
  Callback invoked for dynamically configuring the endpoint.
  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config) do
    if config[:load_from_system_env] do
      port = Application.get_env(:accent, Accent.Endpoint)[:http][:port] || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end
end
