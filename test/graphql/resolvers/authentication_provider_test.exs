defmodule AccentTest.GraphQL.Resolvers.AuthenticationProvider do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Accent.GraphQL.Resolvers.AuthenticationProvider, as: Resolver

  test "list providers" do
    {:ok, providers} = Resolver.list(nil, %{}, %{})

    assert providers === [%{id: :dummy}]
  end
end
