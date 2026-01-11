defmodule Tfz.Release do
  @app :tfz

  def create_and_migrate do
    load_app()
    create()
    migrate()
  end

  def create do
    for repo <- repos() do
      case repo.__adapter__.storage_up(repo.config()) do
        :ok -> :ok
        {:error, :already_up} -> :ok
        other -> raise "storage_up failed for #{inspect(repo)}: #{inspect(other)}"
      end
    end
  end

  def migrate do
    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, fn repo ->
          Ecto.Migrator.run(repo, :up, all: true)
        end)
    end
  end

  defp repos, do: Application.fetch_env!(@app, :ecto_repos)
  defp load_app, do: Application.load(@app)
end
