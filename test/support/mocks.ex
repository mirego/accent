defmodule Accent.Hook.Outbounds.Mock do
  @moduledoc false
  @behaviour Accent.Hook.Events

  use Oban.Worker, queue: :hook

  @impl Accent.Hook.Events
  def registered_events do
    :all
  end

  @impl Oban.Worker
  def perform(_job) do
    :ok
  end
end
