defmodule AccentTest.GraphqlInterface do
  use Accent.ConnCase

  test "graphql", %{conn: conn} do
    response =
      conn
      |> get("/graphql", %{query: "query { __schema { queryType { name } } }"})

    assert response.resp_body == ~S({"data":{"__schema":{"queryType":{"name":"RootQueryType"}}}})
    assert response.status == 200
  end
end
