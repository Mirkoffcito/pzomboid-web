defmodule Tfz.Zomboid.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :username, :string
    field :last_seen_at, :utc_datetime
    timestamps(type: :utc_datetime)
  end

  def changeset(player, attrs) do
    player
    |> cast(attrs, [:username, :last_seen_at])
    |> validate_required([:username])
    |> unique_constraint(:username)
  end
end
