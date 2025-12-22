defmodule Tfz.Repo do
  use Ecto.Repo,
    otp_app: :tfz,
    adapter: Ecto.Adapters.Postgres
end
