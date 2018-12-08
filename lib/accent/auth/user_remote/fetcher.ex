defmodule Accent.UserRemote.Fetcher do
  @moduledoc """
  Fetch a user (email and provider infos) based on a single value.
  """

  alias Accent.UserRemote.Adapters.Google

  def fetch(_provider, ""), do: {:error, %{value: "empty"}}
  def fetch(_provider, nil), do: {:error, %{value: "empty"}}

  def fetch("dummy", value) do
    if Application.get_env(:accent, :dummy_provider_enabled) do
      Accent.UserRemote.Adapters.Dummy.fetch(value)
    else
      fetch(nil, value)
    end
  end

  def fetch("google", value), do: Google.fetch(value)
  def fetch(_provider, _value), do: {:error, %{provider: "unknown"}}
end
