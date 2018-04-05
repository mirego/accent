defmodule Accent.Plugs.SentryUserContext do
  alias Accent.User

  def init(_), do: nil

  @doc """
  Takes some keys in the current_user assign to put it in Sentry’s context
  """
  def call(conn = %{assigns: %{current_user: current_user = %User{}}}, _opts) do
    current_user
    |> Map.take([:id, :email, :fullname])
    |> Sentry.Context.set_user_context()

    conn
  end

  def call(conn, _opts), do: conn
end
