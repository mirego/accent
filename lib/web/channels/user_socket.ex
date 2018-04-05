defmodule Accent.UserSocket do
  use Phoenix.Socket

  alias Accent.{User, UserAuthFetcher}

  channel("projects:*", Accent.ProjectChannel)
  transport(:websocket, Phoenix.Transports.WebSocket, timeout: 45_000)

  def connect(%{"token" => token}, socket) do
    case UserAuthFetcher.fetch(token) do
      user = %User{} -> {:ok, assign(socket, :user, user)}
      nil -> :error
    end
  end

  def connect(_params, _socket), do: :error

  def id(socket), do: "users:#{socket.assigns[:user].id}"
end
