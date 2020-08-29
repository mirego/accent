defmodule Accent.Hook.Outbounds.Discord do
  use Oban.Worker, queue: :hook
  require EEx

  EEx.function_from_file(:def, :sync, "lib/hook/outbounds/discord/templates/sync.eex", [:assigns], trim: true)

  alias Accent.Hook.Outbounds.PostURL

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    context = Accent.Hook.Context.from_worker(args)
    PostURL.perform("discord", &build_body/1).(context)
  end

  defp build_body(%{event: "sync", user: user, payload: %{"document_path" => document_path, "batch_operation_stats" => stats}}) do
    %{
      text: sync(user: user, document_path: document_path, stats: stats)
    }
  end
end
