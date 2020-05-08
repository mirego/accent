defmodule Accent.WebappView do
  def render(conn) do
    config = config()

    :accent
    |> Application.app_dir(config[:path])
    |> File.read!()
    |> replace_env_var(config, conn)
  end

  defp replace_env_var(file, config, conn) do
    default_api_host = Plug.Conn.get_req_header(conn, "host")
    http_scheme = if config[:force_ssl], do: "https://", else: "http://"
    ws_scheme = if config[:force_ssl], do: "wss://", else: "ws://"

    file
    |> String.replace("__API_HOST__", config[:api_host] || "#{http_scheme}#{default_api_host}")
    |> String.replace("__API_WS_HOST__", config[:api_ws_host] || "#{ws_scheme}#{default_api_host}")
    |> String.replace("__WEBAPP_SENTRY_DSN__", config[:sentry_dsn])
    |> String.replace("__VERSION__", version())
  end

  defp version do
    Application.get_env(:accent, :version)
  end

  defp config do
    Application.get_env(:accent, __MODULE__)
  end
end
