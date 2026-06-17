defmodule Accent.Sentry do
  @moduledoc false
  def before_send(%Sentry.Event{original_exception: %DBConnection.ConnectionError{}} = event) do
    %{event | fingerprint: ~w(ecto db_connection timeout)}
  end

  def before_send(event) do
    event
  end
end
