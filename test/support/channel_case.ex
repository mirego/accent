defmodule Accent.ChannelCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  alias Accent.Endpoint
  alias Accent.Repo
  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      import Accent.Router.Helpers
      # Import conveniences for testing with connections
      import Phoenix.ChannelTest

      # The default endpoint for testing
      @endpoint Endpoint

      def to_worker_args(struct) do
        struct
        |> Jason.encode!()
        |> Jason.decode!()
      end
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    {:ok, []}
  end
end
