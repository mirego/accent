defmodule Accent.UserRemote.Adapter.Fetcher do
  alias Accent.UserRemote.Adapter.User

  @callback fetch(String.t()) :: {:ok, User.t()} | {:error, list(String.t())}
end
