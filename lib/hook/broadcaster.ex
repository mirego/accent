defmodule Accent.Hook.Broadcaster do
  @producers [
    Accent.Hook.Producers.Email,
    Accent.Hook.Producers.Websocket,
    Accent.Hook.Producers.Slack
  ]

  @callback fanout(Accent.Hook.Context.t()) :: no_return()
  @timeout 10_000

  def fanout(context = %Accent.Hook.Context{}) do
    for producer <- @producers do
      GenStage.call(producer, {:notify, context}, @timeout)
    end
  end
end
