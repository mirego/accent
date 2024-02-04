defmodule Accent.Endpoint do
  use Phoenix.Endpoint, otp_app: :accent

  socket("/socket", Accent.UserSocket, websocket: true, timeout: 45_000)

  plug(:ping)
  plug(:canonical_host)
  plug(:force_ssl)
  plug(Corsica, origins: "*", allow_headers: ~w(Accept Content-Type Authorization origin))

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug(Plug.Static,
    at: "/static",
    from: {:accent, "priv/static"},
    gzip: true,
    only: ~w(jipt images)
  )

  plug(Plug.Static,
    at: "/",
    from: {:accent, "priv/static/webapp"},
    gzip: true,
    only: ~w(favicon.ico assets index.html robot.txt)
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket, websocket: true)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.Session,
    store: :cookie,
    key: "accent",
    signing_salt: "accent-signing-salt-used-for-callback-auth"
  )

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

  # sobelow_skip ["XSS.SendResp"]
  defp ping(%{request_path: "/ping"} = conn, _opts) do
    alias Plug.Conn

    version = Application.get_env(:accent, :version)

    conn
    |> Conn.put_resp_header("content-type", "application/json")
    |> Conn.send_resp(200, ~s({"status":"ok","version":"#{version}"}))
    |> Conn.halt()
  end

  defp ping(conn, _opts), do: conn

  defp canonical_host(%{request_path: "/health"} = conn, _opts), do: conn

  defp canonical_host(conn, _opts) do
    opts = PlugCanonicalHost.init(canonical_host: Application.get_env(:accent, :canonical_host))

    PlugCanonicalHost.call(conn, opts)
  end
end
