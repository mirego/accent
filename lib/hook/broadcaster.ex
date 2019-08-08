defmodule Accent.Hook.Broadcaster do
  @notifiers [
    Accent.Hook.Producers.Email,
    Accent.Hook.Producers.Websocket,
    Accent.Hook.Producers.Slack,
    Accent.Hook.Producers.Discord
  ]

  @callback notify(Accent.Hook.Context.t()) :: no_return()
  @callback external_document_update(:github, Accent.Hook.Context.t()) :: no_return()

  @timeout 10_000

  def notify(context = %Accent.Hook.Context{}) do
    for producer <- @notifiers do
      GenStage.call(producer, {:notify, context}, @timeout)
    end
  end

  def external_document_update(:github, context = %Accent.Hook.Context{}) do
    GenStage.call(Accent.Hook.Producers.GitHub, {:external_document_update, context}, @timeout)
  end
end
