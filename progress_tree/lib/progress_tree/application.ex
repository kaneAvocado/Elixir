defmodule ProgressTree.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ProgressTreeWeb.Telemetry,
      ProgressTree.Repo,
      {DNSCluster, query: Application.get_env(:progress_tree, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ProgressTree.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ProgressTree.Finch},
      # Start a worker by calling: ProgressTree.Worker.start_link(arg)
      # {ProgressTree.Worker, arg},
      # Start to serve requests, typically the last entry
      ProgressTreeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ProgressTree.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ProgressTreeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
