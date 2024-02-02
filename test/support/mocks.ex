defmodule Accent.Hook.Outbounds.Mock do
  @moduledoc false
  use Oban.Worker, queue: :hook

  @impl Oban.Worker
  def perform(_job) do
    :ok
  end
end
