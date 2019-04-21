defmodule Accent.Hook.Broadcaster do
  @notifiers [
    Accent.Hook.Producers.Email,
    Accent.Hook.Producers.Websocket,
    Accent.Hook.Producers.Slack
  ]

  @callback notify(Accent.Hook.Context.t()) :: no_return()
  @callback external_document_update(Accent.Hook.Context.t()) :: no_return()

  @notify_timeout 10_000

  def notify(context = %Accent.Hook.Context{}) do
    for producer <- @notifiers do
      GenStage.call(producer, {:notify, context}, @notify_timeout)
    end
  end

  def external_document_update(:github, context = %Accent.Hook.Context{}) do
    GenStage.call(Accent.Hook.Producers.GitHub, {:external_document_update, context}, :infinity)
  end
end
