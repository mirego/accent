defmodule Accent.WebappView do
  @subresource_integrity ~r/ integrity="(sha256-.+)?"/

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
    |> remove_subresource_integrity(skip_subresource_integrity())
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

  defp skip_subresource_integrity do
    Application.get_env(:accent, __MODULE__)[:skip_subresource_integrity]
  end

  defp remove_subresource_integrity(content, false), do: content

  defp remove_subresource_integrity(content, _) do
    String.replace(content, @subresource_integrity, "")
  end
end
