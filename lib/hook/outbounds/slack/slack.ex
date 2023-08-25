defmodule Accent.Hook.Outbounds.Slack do
  @moduledoc false
  use Oban.Worker, queue: :hook

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    context = Accent.Hook.Context.from_worker(args)
    http_body = fn content -> %{text: content} end

    Accent.Hook.Outbounds.PostURL.perform("slack", context,
      http_body: http_body,
      templates: Hook.Outbounds.Slack.Templates
    )
  end
end
