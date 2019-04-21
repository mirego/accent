defmodule Accent.Hook.Consumers.GitHub.FileServer.HTTP do
  use HTTPoison.Base

  @behaviour Accent.Hook.Consumers.GitHub.FileServer

  @base_url "https://api.github.com/repos/"

  def process_url(@base_url <> path), do: process_url(path)
  def process_url(path), do: @base_url <> path

  def process_response_body(body) do
    body
    |> Jason.decode()
    |> case do
      {:ok, body} -> body
      _ -> :error
    end
  end
end
