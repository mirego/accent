defmodule Accent.Plugs.SentryUserContext do
  def init(_), do: nil

  @doc """
  Takes some keys in the current_user assign to put it in Sentry’s context
  """
  def call(conn = %{assigns: %{current_user: current_user = %{}}}, _opts) do
    current_user
    |> Map.take(~w(id email fullname)a)
    |> Sentry.Context.set_user_context()

    conn
  end

  def call(conn, _opts), do: conn
end
