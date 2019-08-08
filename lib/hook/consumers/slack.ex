defmodule Accent.Hook.Consumers.Slack do
  use Accent.Hook.EventConsumer, subscribe_to: [Accent.Hook.Producers.Slack]

  alias Accent.Hook.Consumers.PostURL
  alias Accent.Hook.Context

  @service "slack"
  @supported_events ~w(sync)

  def handle_events(events, _from, state) do
    events
    |> Enum.filter(&filter_event/1)
    |> Enum.each(fn event ->
      PostURL.handle_event(@service, &build_body/1).(event, state)
    end)

    {:noreply, [], state}
  end

  defp filter_event(%Context{event: event}), do: event in @supported_events

  defp build_body(%Context{event: "sync", user: user, payload: %{document_path: document_path, batch_operation_stats: stats}}) do
    %{
      text: """
      *#{user.fullname}* just synced a file: _#{document_path}_

      *Stats:*
      #{build_stats(stats)}
      """
    }
  end

  defp build_stats(stats) do
    Enum.reduce(stats, "", fn %{action: action, count: count}, acc ->
      "#{acc}#{action}: _#{count}_\n"
    end)
  end
end
