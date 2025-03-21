defmodule Accent.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  alias Accent.Endpoint
  alias Ecto.Adapters.SQL.Sandbox
  alias Phoenix.ConnTest

  using do
    quote do
      use Oban.Testing, repo: Accent.Repo

      # Import conveniences for testing with connections
      import Accent.Router.Helpers
      import Phoenix.ConnTest
      import Plug.Conn

      alias Accent.Factory

      # The default endpoint for testing
      @endpoint Endpoint
    end
  end

  setup tags do
    setup_sandbox(tags)

    {:ok, conn: Plug.Test.init_test_session(ConnTest.build_conn(), [])}
  end

  def setup_sandbox(tags) do
    pid = Sandbox.start_owner!(Accent.Repo, shared: not tags[:async])
    on_exit(fn -> Sandbox.stop_owner(pid) end)
  end
end
