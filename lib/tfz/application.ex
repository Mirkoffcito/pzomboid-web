defmodule Tfz.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TfzWeb.Telemetry,
      Tfz.Repo,
      {DNSCluster, query: Application.get_env(:tfz, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Tfz.PubSub},
      # Start a worker by calling: Tfz.Worker.start_link(arg)
      # {Tfz.Worker, arg},
      # Start to serve requests, typically the last entry
      TfzWeb.Endpoint,
      Tfz.Zomboid.PlayerTracker
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tfz.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TfzWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
