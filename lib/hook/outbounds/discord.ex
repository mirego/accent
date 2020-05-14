defmodule Accent.Hook.Outbounds.Discord do
  use Oban.Worker, queue: :hook

  alias Accent.Hook.Outbounds.PostURL

  @impl Oban.Worker
  def perform(context, _job) do
    context = Accent.Hook.Context.from_worker(context)
    PostURL.perform("discord", &build_body/1).(context)
  end

  defp build_body(%{event: "sync", user: user, payload: %{"document_path" => document_path, "batch_operation_stats" => stats}}) do
    %{
      text: """
      **#{user.fullname}** just synced a file: *#{document_path}*

      **Stats:**
      #{build_stats(stats)}
      """
    }
  end

  defp build_stats(stats) do
    Enum.reduce(stats, "", fn %{"action" => action, "count" => count}, acc ->
      "#{acc}#{action}: *#{count}*\n"
    end)
  end
end
