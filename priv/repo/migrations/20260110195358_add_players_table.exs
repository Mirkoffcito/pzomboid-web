defmodule Tfz.Repo.Migrations.AddPlayersTable do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :username, :string, null: false
      add :last_seen_at, :utc_datetime, null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:players, [:username])
  end

end
