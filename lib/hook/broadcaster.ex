defmodule Accent.Hook.Broadcaster do
  @producers [
    Accent.Hook.Producers.Email,
    Accent.Hook.Producers.Websocket,
    Accent.Hook.Producers.Slack
  ]

  @callback fanout(Accent.Hook.Context.t()) :: no_return()

  def fanout(context = %Accent.Hook.Context{}, timeout \\ 5000) do
    for producer <- @producers do
      GenStage.call(producer, {:notify, context}, timeout)
    end
  end
end
