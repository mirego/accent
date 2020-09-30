defmodule Accent.Plugs.GraphQLOperationNameLogger do
  @behaviour Plug

  def init(options), do: options

  def call(conn = %{params: %{"operationName" => name, "query" => _}}, _) do
    put_metadata(name)
    conn
  end

  def call(conn = %{params: %{"_json" => operations}}, _) do
    operation_names =
      operations
      |> Enum.filter(&Map.has_key?(&1, "operationName"))
      |> Enum.map(& &1["operationName"])
      |> Enum.join(",")

    put_metadata(operation_names)
    conn
  end

  def call(conn, _), do: conn

  defp put_metadata(operation_name) do
    Logger.metadata(graphql_operation: operation_name)
  end
end
