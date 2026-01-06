defmodule Tfz.Zomboid.PlayerTracker do
  use GenServer

  @topic "zomboid:players"

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def subscribe, do: Phoenix.PubSub.subscribe(Tfz.PubSub, @topic)

  def snapshot, do: GenServer.call(__MODULE__, :snapshot)

  @impl true
  def init(_) do
    state = %{players: [], last_updated: nil, status: :starting}
    schedule_refresh(0)
    {:ok, state}
  end

  @impl true
  def handle_call(:snapshot, _from, state), do: {:reply, state, state}

  @impl true
  def handle_info(:refresh, state) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    new_state =
      case Tfz.Zomboid.Rcon.players() do
        {:ok, players} ->
          %{state | players: players, last_updated: now, status: :ok}

        {:error, reason} ->
          %{state | last_updated: now, status: {:error, reason}}
      end

    Phoenix.PubSub.broadcast(Tfz.PubSub, @topic, {:players_update, new_state})
    schedule_refresh(poll_ms())
    {:noreply, new_state}
  end


  defp poll_ms do
    System.get_env("RCON_POLL_MS", "5000")
    |> String.to_integer()
  end

  defp schedule_refresh(ms), do: Process.send_after(self(), :refresh, ms)
end
