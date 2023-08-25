defmodule Accent.Hook.Outbounds.Discord do
  @moduledoc false
  use Oban.Worker, queue: :hook

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    context = Accent.Hook.Context.from_worker(args)
    Accent.Hook.Outbounds.PostURL.perform("discord", context, Hook.Outbounds.Discord.Templates)
  end
end
