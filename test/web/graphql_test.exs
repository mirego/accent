defmodule AccentTest.GraphqlInterface do
  @moduledoc false
  use Accent.ConnCase

  test "graphql", %{conn: conn} do
    response = get(conn, "/graphql", %{query: "query { __schema { queryType { name } } }"})

    assert response.resp_body == ~S({"data":{"__schema":{"queryType":{"name":"RootQueryType"}}}})
    assert response.status == 200
  end
end
