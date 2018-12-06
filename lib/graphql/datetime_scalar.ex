defmodule Accent.GraphQL.DatetimeScalar do
  use Absinthe.Schema.Notation

  @moduledoc """
  This module contains additional data types.
  To use: `import_types Absinthe.Type.Extensions`.
  """

  scalar :datetime, name: "DateTime" do
    description("""
    The `DateTime` scalar type represents a date and time in the UTC
    timezone. The DateTime appears in a JSON response as an ISO8601 formatted
    string, including UTC timezone ("Z").
    """)

    serialize(&serialize_datetime/1)
    parse(parse_with([Absinthe.Blueprint.Input.DateTime], &parse_datetime/1))
  end

  @spec parse_datetime(any) :: {:ok, DateTime.t()} | :error
  defp parse_datetime(value) when is_binary(value) do
    DateTime.from_iso8601(value)
  end

  defp parse_datetime(_) do
    :error
  end

  @spec serialize_datetime(any) :: {:ok, String.t()} | :error
  defp serialize_datetime(datetime = %DateTime{}) do
    datetime
    |> DateTime.to_iso8601()
  end

  defp serialize_datetime(_) do
    :error
  end

  # Parse, supporting pulling values out of blueprint Input nodes
  defp parse_with(node_types, coercion) do
    fn
      %{__struct__: str, value: value} ->
        if str in node_types do
          coercion.(value)
        else
          :error
        end

      other ->
        coercion.(other)
    end
  end
end
