defmodule Accent.AccessTokenUsageWriter do
  @moduledoc """
  Buffers API token usage timestamps and flushes to DB every minute.
  Deduplicates tokens within the flush window to minimize writes.
  """
  use GenServer

  import Ecto.Query

  alias Accent.AccessToken
  alias Accent.Repo

  @flush_interval to_timeout(minute: 1)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Track that an API token was used. This is async and non-blocking.
  """
  def track_usage(token_id) do
    GenServer.cast(__MODULE__, {:track, token_id})
  end

  @impl true
  def init(_) do
    schedule_flush()
    {:ok, MapSet.new()}
  end

  @impl true
  def handle_cast({:track, token_id}, state) do
    {:noreply, MapSet.put(state, token_id)}
  end

  @impl true
  def handle_info(:flush, state) do
    flush_to_db(state)
    schedule_flush()
    {:noreply, MapSet.new()}
  end

  defp schedule_flush do
    Process.send_after(self(), :flush, @flush_interval)
  end

  defp flush_to_db(token_ids) do
    if MapSet.size(token_ids) > 0 do
      now = DateTime.utc_now()
      ids = MapSet.to_list(token_ids)

      for ids <- Enum.chunk_every(ids, 1000) do
        Repo.update_all(
          from(t in AccessToken, where: t.id in ^ids),
          set: [last_used_at: now]
        )
      end
    end

    :ok
  end
end
