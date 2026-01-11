defmodule Tfz.Repo.Migrations.MakeLastSeenNullable do
  use Ecto.Migration

  def change do
    alter table(:players) do
      modify :last_seen_at, :utc_datetime, null: true
    end
  end
end
