defmodule Accent do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(Accent.Endpoint, []),
      # Start the Ecto repository
      worker(Accent.Repo, []),
      worker(Accent.Hook.Producers.Email, []),
      worker(Accent.Hook.Consumers.Email, []),
      worker(Accent.Hook.Producers.Websocket, []),
      worker(Accent.Hook.Consumers.Websocket, []),
      worker(Accent.Hook.Producers.Slack, []),
      worker(Accent.Hook.Consumers.Slack, http_client: HTTPoison)
    ]

    :ok = :error_logger.add_report_handler(Sentry.Logger)

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Accent.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Accent.Endpoint.config_change(changed, removed)
    :ok
  end
end
