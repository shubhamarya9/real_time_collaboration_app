defmodule RealTimeCollaborationApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RealTimeCollaborationAppWeb.Telemetry,
      RealTimeCollaborationApp.Repo,
      {DNSCluster, query: Application.get_env(:real_time_collaboration_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RealTimeCollaborationApp.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: RealTimeCollaborationApp.Finch},
      # Start a worker by calling: RealTimeCollaborationApp.Worker.start_link(arg)
      # {RealTimeCollaborationApp.Worker, arg},
      # Start to serve requests, typically the last entry
      RealTimeCollaborationAppWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RealTimeCollaborationApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RealTimeCollaborationAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
