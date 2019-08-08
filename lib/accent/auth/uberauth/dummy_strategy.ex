defmodule Accent.Auth.Ueberauth.DummyStrategy do
  @moduledoc """
  A username strategy for Ueberauth
  """

  use Ueberauth.Strategy

  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra
  alias Ueberauth.Auth.Info

  @doc """
  iex> uid(%Plug.Conn{params: %{"email" => "foo"}})
  "foo"
  """
  @impl Ueberauth.Strategy
  def uid(conn) do
    conn.params["email"]
  end

  @doc """
  iex> info(%Plug.Conn{params: %{"email" => "foo"}})
  %Ueberauth.Auth.Info{email: "foo"}
  """
  @impl Ueberauth.Strategy
  def info(conn) do
    %Info{email: conn.params["email"]}
  end

  @doc """
  iex> credentials(%Plug.Conn{})
  %Ueberauth.Auth.Credentials{}
  """
  @impl Ueberauth.Strategy
  def credentials(_conn) do
    %Credentials{}
  end

  @doc """
  iex> extra(%Plug.Conn{params: %{"email" => "foo"}})
  %Ueberauth.Auth.Extra{raw_info: %{"email" => "foo"}}
  """
  @impl Ueberauth.Strategy
  def extra(conn) do
    %Extra{raw_info: conn.params}
  end
end
