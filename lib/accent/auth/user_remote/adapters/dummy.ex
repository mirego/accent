if Application.get_env(:accent, :dummy_provider_enabled) do
  defmodule Accent.UserRemote.Adapters.Dummy do
    @moduledoc """
    This is the simplest adapter for user remote fetching.

    It simply returns the value as both the email and the uid.
    """

    @behaviour Accent.UserRemote.Adapter.Fetcher
    @name "dummy"

    alias Accent.UserRemote.Adapter.User

    def fetch(value) when value === "", do: {:error, ["invalid email"]}
    def fetch(value), do: {:ok, %User{email: String.downcase(value), provider: @name, uid: value}}
  end
end
