defmodule Accent.Sentry do
  def before_send(%{exception: [%{type: DBConnection.ConnectionError}]} = event) do
    %{event | fingerprint: ~w(ecto db_connection timeout)}
  end

  def before_send(event) do
    event
  end
end
