defmodule Tfz.Zomboid.Players do
  @moduledoc false
  import Ecto.Query
  alias Tfz.Repo
  alias Tfz.Zomboid.Player

  def mark_seen(usernames) when is_list(usernames) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    mark_seen_at(usernames, now)
  end

  def mark_seen_at(usernames, %DateTime{} = now) when is_list(usernames) do
    rows =
      usernames
      |> Enum.uniq()
      |> Enum.map(fn u ->
        %{
          username: u,
          last_seen_at: now,
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(Player, rows,
      conflict_target: :username,
      on_conflict: [set: [last_seen_at: now, updated_at: now]]
    )
  end

  def list_recent(limit \\ 50) do
    from(p in Player,
      order_by: [desc: p.last_seen_at],
      limit: ^limit
    )
    |> Repo.all()
  end
end
