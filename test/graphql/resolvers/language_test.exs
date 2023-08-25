defmodule AccentTest.GraphQL.Resolvers.Language do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.GraphQL.Resolvers.Language, as: Resolver

  test "list" do
    {:ok, result} = Resolver.list(nil, %{page_size: 10}, %{})

    assert length(result.entries) == 10
  end

  test "list search" do
    {:ok, result} = Resolver.list(nil, %{query: "mbourgis"}, %{})

    assert get_in(result, [:entries, Access.all(), Access.key(:name)]) == ["Luxembourgish"]
  end

  test "list empty search" do
    {:ok, result} = Resolver.list(nil, %{query: "", page_size: 10}, %{})

    assert length(result.entries) == 10
  end
end
