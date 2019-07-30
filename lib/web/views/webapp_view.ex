defmodule Accent.WebappView do
  def render do
    config = config()

    :accent
    |> Application.app_dir(config[:path])
    |> File.read!()
    |> replace_env_var(config)
  end

  defp replace_env_var(file, config) do
    file
    |> String.replace("__API_HOST__", config[:api_host])
    |> String.replace("__API_WS_HOST__", config[:api_ws_host])
    |> String.replace("__WEBAPP_SENTRY_DSN__", config[:sentry_dsn])
  end

  defp config do
    Application.get_env(:accent, __MODULE__)
  end
end
