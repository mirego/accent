defmodule Accent.Sentry do
  def before_send(event = %{exception: [%{type: DBConnection.ConnectionError}]}) do
    %{event | fingerprint: ~w(ecto db_connection timeout)}
  end

  def before_send(event) do
    event
  end
end
