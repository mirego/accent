defmodule AccentTest.GraphiqlInterface do
  @moduledoc false
  use Accent.ConnCase

  test "graphiql", %{conn: conn} do
    response = get(conn, "/graphiql", %{query: "query { __schema { queryType { name } } }"})

    assert response.resp_body == ~S({"data":{"__schema":{"queryType":{"name":"RootQueryType"}}}})
    assert response.status == 200
  end
end
