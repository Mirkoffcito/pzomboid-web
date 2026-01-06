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
       status: snap.status,
       server: Tfz.Zomboid.ServerInfo.info(),
       page_title: "Team Fusa - Zomboid"
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

  # CSS Classes to use depending on returned status
  defp status_badge(:ok), do: "badge-success"
  defp status_badge({:error, _}), do: "badge-error"
  defp status_badge(:starting), do: "badge-warning"
  defp status_badge(_), do: "badge-warning"

  defp status_label(:ok), do: "EN LINEA"
  defp status_label({:error, _}), do: "APAGADO"
  defp status_label(:starting), do: "INICIANDO"
  defp status_label(_), do: "DESCONOCIDO"
end
