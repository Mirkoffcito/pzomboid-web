defmodule TfzWeb.PlayersLive do
  use TfzWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Tfz.Zomboid.PlayerTracker.subscribe()

    snap = Tfz.Zomboid.PlayerTracker.snapshot()

    {:ok,
     assign(socket,
       players: snap.players,
       last_updated: snap.last_updated,
       status: snap.status
     )}
  end

  @impl true
  def handle_info({:players_update, snap}, socket) do
    {:noreply,
     assign(socket,
       players: snap.players,
       last_updated: snap.last_updated,
       status: snap.status
     )}
  end
end
