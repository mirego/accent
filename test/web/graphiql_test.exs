defmodule AccentTest.GraphiqlInterface do
  use Accent.ConnCase

  test "graphiql", %{conn: conn} do
    response =
      conn
      |> get("/graphiql", %{query: "query { __schema { queryType { name } } }"})

    assert response.resp_body == ~S({"data":{"__schema":{"queryType":{"name":"RootQueryType"}}}})
    assert response.status == 200
  end
end
