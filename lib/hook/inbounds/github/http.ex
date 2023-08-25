defmodule Accent.Hook.Inbounds.GitHub.FileServer.HTTP do
  @moduledoc false
  @behaviour Accent.Hook.Inbounds.GitHub.FileServer

  use HTTPoison.Base

  @base_url "https://api.github.com/repos/"

  @impl true
  def get_path(path, options), do: get(path, options)

  @impl true
  def process_url(@base_url <> path), do: process_url(path)
  def process_url(path), do: @base_url <> path

  @impl true
  def process_response_body(body) do
    body
    |> Jason.decode()
    |> case do
      {:ok, body} -> body
      _ -> :error
    end
  end
end
