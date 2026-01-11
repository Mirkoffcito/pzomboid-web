defmodule TfzWeb.PlayersController do
  use TfzWeb, :controller
  alias Tfz.Zomboid.Players

  def index(conn, _params) do
    players = Players.list_recent(200)
    render(conn, :index, players: players, nav_active: :players)
  end
end
