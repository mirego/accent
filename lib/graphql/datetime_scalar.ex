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
    parse(fn _ -> :error end)
  end

  @spec serialize_datetime(any) :: {:ok, String.t()} | :error
  defp serialize_datetime(datetime = %DateTime{}) do
    datetime
    |> DateTime.to_iso8601()
  end

  defp serialize_datetime(_) do
    :error
  end
end
