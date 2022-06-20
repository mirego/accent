defmodule Accent do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Accent.Endpoint,
      Accent.Repo,
      {Oban, oban_config()},
      {Phoenix.PubSub, [name: Accent.PubSub, adapter: Phoenix.PubSub.PG2]}
    ]

    if Application.get_env(:sentry, :dsn) do
      {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)
    end

    opts = [strategy: :one_for_one, name: Accent.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Accent.Endpoint.config_change(changed, removed)
    :ok
  end

  defp oban_config do
    opts = Application.get_env(:accent, Oban)

    # Prevent running queues or scheduling jobs from an iex console.
    if Code.ensure_loaded?(IEx) and IEx.started?() do
      opts
      |> Keyword.put(:crontab, false)
      |> Keyword.put(:queues, false)
    else
      opts
    end
  end
end
