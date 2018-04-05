defmodule AccentTest.Plugs.GraphQLContext do
  use ExUnit.Case
  use Plug.Test

  alias Accent.Plugs.GraphQLContext

  test "assign conn" do
    origin_conn = conn(:get, "/foo")

    assert origin_conn ==
             origin_conn
             |> GraphQLContext.call(GraphQLContext.init([]))
             |> get_in([Access.key(:private), :absinthe, :context, :conn])
  end
end
