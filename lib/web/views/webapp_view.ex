defmodule Accent.WebappView do
  def render do
    :accent
    |> Application.app_dir(path())
    |> File.read!()
    |> replace_env_var()
  end

  defp replace_env_var(file) do
    file
    |> String.replace("__WEBAPP_SENTRY_DSN__", sentry_dsn())
    |> String.replace("__VERSION__", version())
  end

  defp version do
    Application.get_env(:accent, :version)
  end

  defp sentry_dsn do
    Application.get_env(:accent, __MODULE__)[:sentry_dsn]
  end

  defp path do
    Application.get_env(:accent, __MODULE__)[:path]
  end
end
