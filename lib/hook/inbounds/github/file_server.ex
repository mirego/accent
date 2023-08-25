defmodule Accent.Hook.Inbounds.GitHub.FileServer do
  @moduledoc false
  @callback get_path(String.t(), list()) :: {:ok, String.t()} | {:error, any()}
end
