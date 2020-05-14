defmodule Accent.Hook.Inbounds.GitHub.FileServer do
  @callback get_path(String.t(), list()) :: {:ok, String.t()} | {:error, any()}
end
