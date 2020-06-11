Mox.defmock(Accent.Hook.Inbounds.GitHub.FileServerMock, for: Accent.Hook.Inbounds.GitHub.FileServer)

defmodule Accent.Hook.Inbounds.Mock do
  use Oban.Worker, queue: :hook

  @impl Oban.Worker
  def perform(_context, _job) do
    :ok
  end
end

defmodule Accent.Hook.Outbounds.Mock do
  use Oban.Worker, queue: :hook

  @impl Oban.Worker
  def perform(_context, _job) do
    :ok
  end
end
