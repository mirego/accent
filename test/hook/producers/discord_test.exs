defmodule DiscordTestConsumer do
  use GenStage

  def start_link(producer) do
    GenStage.start_link(__MODULE__, {producer, self()})
  end

  def init({producer, owner}) do
    {:consumer, owner, subscribe_to: [producer]}
  end

  def handle_events(events, _from, owner) do
    send(owner, {:received, events})
    {:noreply, [], owner}
  end
end

defmodule AccentTest.Hook.Producers.Discord do
  use ExUnit.Case, async: true

  test "a subscribed observer is notified of all events" do
    {:ok, stage} = GenStage.start_link(Accent.Hook.Producers.Discord, :ok)
    {:ok, _} = DiscordTestConsumer.start_link(stage)

    GenStage.call(stage, {:notify, "LOL"})

    assert_receive {:received, events}
    assert events == ["LOL"]

    GenStage.stop(stage)
  end
end
