defmodule Accent.Hook.Outbounds.Slack do
  use Oban.Worker, queue: :hook
  require EEx

  EEx.function_from_file(:def, :sync, "lib/hook/outbounds/slack/templates/sync.eex", [:assigns], trim: true)

  alias Accent.Hook.Outbounds.PostURL

  @impl Oban.Worker
  def perform(context, _job) do
    context = Accent.Hook.Context.from_worker(context)
    PostURL.perform("slack", &build_body/1).(context)
  end

  defp build_body(%{event: "sync", user: user, payload: %{"document_path" => document_path, "batch_operation_stats" => stats}}) do
    %{
      text: sync(user: user, document_path: document_path, stats: stats)
    }
  end
end
