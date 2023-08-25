defmodule Accent.Hook.Outbounds.Slack do
  @moduledoc false
  use Oban.Worker, queue: :hook

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    context = Accent.Hook.Context.from_worker(args)
    Accent.Hook.Outbounds.PostURL.perform("slack", context, Hook.Outbounds.Slack.Templates)
  end
end
