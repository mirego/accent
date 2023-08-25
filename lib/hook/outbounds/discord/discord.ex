defmodule Accent.Hook.Outbounds.Discord do
  @moduledoc false
  use Oban.Worker, queue: :hook

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    context = Accent.Hook.Context.from_worker(args)
    http_body = fn content -> %{content: content} end

    Accent.Hook.Outbounds.PostURL.perform("discord", context,
      http_body: http_body,
      templates: Hook.Outbounds.Discord.Templates
    )
  end
end
