defmodule Accent.Hook.Consumers.GitHub.FileServer do
  @callback get(String.t(), list()) :: {:ok, String.t()} | {:error, any()}
end
