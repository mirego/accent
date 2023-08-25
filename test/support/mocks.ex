Mox.defmock(Accent.Hook.Inbounds.GitHub.FileServerMock, for: Accent.Hook.Inbounds.GitHub.FileServer)

defmodule Accent.Hook.Inbounds.Mock do
  @moduledoc false
  use Oban.Worker, queue: :hook

  @impl Oban.Worker
  def perform(_job) do
    :ok
  end
end

defmodule Accent.Hook.Outbounds.Mock do
  @moduledoc false
  use Oban.Worker, queue: :hook

  @impl Oban.Worker
  def perform(_job) do
    :ok
  end
end
